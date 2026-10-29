# Interactive shell setup. Environment and PATH live in .zshenv.

# Profiling: ZSH_PROFILE=1 zsh -i
[[ -n $ZSH_PROFILE ]] && zmodload zsh/zprof

# --- Options and history ---
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt NONOMATCH
setopt PROMPT_SUBST
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# --- Key bindings ---
bindkey "\e[1;3D" backward-word     # ⌥←
bindkey "\e[1;3C" forward-word      # ⌥→
bindkey "^[[1;9D" beginning-of-line # cmd+←
bindkey "^[[1;9C" end-of-line       # cmd+→
bindkey "\e\x7f" backward-kill-word # ⌥⌫
bindkey "\e^H" backward-kill-word

# --- Aliases ---
alias gs="git status"
alias gc="git commit -v"
alias ga="git add ."
alias gd="git diff"
alias gl="git log"
alias gw="git wip"
alias guw="git unwip"

alias ls="ls -G"
alias ll="ls -lhF"
alias lsp="ls -lhtF"

alias ws="cd ~/workspace"

alias python="python3"
alias pip="pip3"

# GPG pinentry needs the controlling terminal of each interactive shell
export GPG_TTY=$TTY

# --- Completion ---
zstyle ':completion:*' matcher-list 'm:{a-z1-9}={A-Z1-9}' # case-insensitive
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ''             # terminal colors

# Full compinit only if the dump is >24h old (glob qualifiers need array context; touch resets the window).
autoload -Uz compinit
_zcompdump=${ZDOTDIR:-$HOME}/.zcompdump
_zcompdump_fresh=( $_zcompdump(N.m-1) )
if (( $#_zcompdump_fresh )); then
  compinit -C
else
  compinit
  [[ -f $_zcompdump ]] && touch -- $_zcompdump
fi
unset _zcompdump _zcompdump_fresh

# Terraform ships bash-style completion; load it lazily on first Tab.
if (( $+commands[terraform] )); then
  _terraform_lazy_complete() {
    compdef -d terraform
    autoload -Uz bashcompinit && bashcompinit
    complete -o nospace -C "$commands[terraform]" terraform
    _normal
  }
  compdef _terraform_lazy_complete terraform
fi

# --- Hooks ---
# -U keeps hooks unique when this file is re-sourced
typeset -gU precmd_functions chpwd_functions
if (( $+commands[direnv] )); then
  _direnv_hook() {
    trap -- '' SIGINT
    eval "$(direnv export zsh)"
    trap - SIGINT
  }
  precmd_functions+=(_direnv_hook)
  chpwd_functions+=(_direnv_hook)
fi

# --- Tool init ---
# zstat -L: Homebrew bottles keep their build time, but the bin/ symlink is recreated on upgrade.
zmodload -F zsh/stat b:zstat
_cached_init() {
  local cmd=$1 cache="${ZSH_CACHE_DIR:-$HOME/.cache}/zsh_$2"
  local -a bin_mtime cache_mtime
  shift 2
  (( $+commands[$cmd] )) || return
  # zstat -A avoids a fork per $(...) on startup.
  if [[ ! -s "$cache" ]] ||
     ! zstat -L -A bin_mtime +mtime -- "$commands[$cmd]" ||
     ! zstat -A cache_mtime +mtime -- "$cache" ||
     (( bin_mtime[1] > cache_mtime[1] )); then
    # Temp file so a concurrent shell never sources a partial cache.
    local tmp="$cache.$$"
    mkdir -p "${cache:h}"
    if "$@" >| "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
      mv -f "$tmp" "$cache"
    else
      rm -f "$tmp"
    fi
  fi
  [[ -s "$cache" ]] && source "$cache"
}

_cached_init npm npm_completion npm completion
_cached_init fzf fzf fzf --zsh
_cached_init zoxide zoxide zoxide init zsh
unfunction _cached_init

# --- Search ---
# Live search: ripgrep reloads on every keystroke, Enter opens the match.
fif() {
  if ! (( $+commands[rg] )); then
    echo "fif: 'rg' (ripgrep) not found." >&2
    return 1
  fi
  if ! (( $+commands[fzf] )); then
    echo "fif: 'fzf' not found." >&2
    return 1
  fi

  # Tab separator, not ':', so paths containing ':' split correctly.
  local RG_PREFIX="rg --column --line-number --no-heading --color=always --field-match-separator '\\t'"
  local preview_cmd='cat {1}'

  if (( $+commands[bat] )); then
    preview_cmd='bat --paging=never --color=always --style=numbers {1} --highlight-line {2}'
  fi

  # become() makes fzf exit with the editor's status (non-zero on cancel); the Ctrl+F widget relies on it.
  fzf --ansi \
    --disabled --query "$*" \
    --bind "start:reload:$RG_PREFIX -- {q} || true" \
    --bind "change:reload:$RG_PREFIX -- {q} || true" \
    --bind "enter:become(${EDITOR:-vim} {1} +{2})" \
    --delimiter '\t' \
    --preview "$preview_cmd" \
    --preview-window 'right:60%,border-left,+{2}-5' \
    --prompt 'Search Content: ' \
    --header "Press Enter to open in ${EDITOR:-vim} | ESC to cancel"
}

fif-widget() {
  zle -I
  fif "$BUFFER" && BUFFER=""
  zle -R
}
zle -N fif-widget
bindkey '^F' fif-widget

[[ -f ~/fzf-git.sh ]] && source ~/fzf-git.sh # https://github.com/junegunn/fzf-git.sh

# --- Prompt ---
# Pure formatter; test/zshrc_git_prompt.zsh extracts it between the markers.
# >>> git-prompt-format
# Sets GIT_PS1 from `git status --branch --porcelain=v1` output.
_git_prompt_format() {
  GIT_PS1=""
  [[ -z $1 ]] && return

  local -a lines
  lines=(${(f)1})

  # First line, e.g. "## master...origin/master [ahead 1]"
  local line1=$lines[1]
  local branch=${line1#\#\# }
  branch=${branch#No commits yet on }
  branch=${branch%%...*}

  local markers=""
  # Match only the bracketed part (branch names may contain these words)
  if [[ "$line1" == *'['* ]]; then
    local upstream=${line1#*\[}
    [[ "$upstream" == *"behind"* ]] && markers+="<"
    [[ "$upstream" == *"ahead"* ]] && markers+=">"
    [[ "$upstream" == *"gone"* ]] && markers+="!"
  elif [[ "$line1" == *"..."* ]]; then
    markers+="="
  fi

  local -a body
  body=("${(@)lines[2,-1]}")
  (( ${#body[(r)[^ ?]*]} )) && markers+="+"   # staged: first column not space or ?
  (( ${#body[(r)?[^ ?]*]} )) && markers+="*"  # dirty: second column not space or ?
  (( ${#body[(r)\?\?*]} )) && markers+="?"    # untracked

  branch=${branch//\%/%%} # stop prompt expansion of %
  GIT_PS1=" [$branch${markers:+ $markers}]"
}
# <<< git-prompt-format

_update_git_prompt() {
  # GIT_OPTIONAL_LOCKS=0 avoids index.lock contention with concurrent git commands.
  _git_prompt_format "$(GIT_OPTIONAL_LOCKS=0 git status --branch --porcelain=v1 --untracked-files=normal 2>/dev/null)"
}
precmd_functions+=(_update_git_prompt)

PS1='%c${GIT_PS1} $ '

# --- Local overrides (sourced last) ---
[[ -f ~/.workrc ]] && source ~/.workrc
[[ -f ~/.pirc ]] && source ~/.pirc

[[ -n $ZSH_PROFILE ]] && zprof
