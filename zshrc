# Interactive shell setup. Environment and PATH live in .zshenv.

# =============================================================================
# Benchmarking (Set ZSH_PROFILE=1 to profile startup)
# =============================================================================
[[ -n $ZSH_PROFILE ]] && zmodload zsh/zprof

# =============================================================================
# Options & History
# =============================================================================
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

# =============================================================================
# Key Bindings (Terminal / Ghostty)
# =============================================================================
bindkey "\e[1;3D" backward-word     # ⌥←
bindkey "\e[1;3C" forward-word      # ⌥→
bindkey "^[[1;9D" beginning-of-line # cmd+←
bindkey "^[[1;9C" end-of-line       # cmd+→

# Opt+Backspace to delete previous word
bindkey "\e\x7f" backward-kill-word
bindkey "\e^H" backward-kill-word

# =============================================================================
# Aliases & Functions
# =============================================================================
alias gs="git status"
alias ls="ls -G"
alias lsp="ls -lhtF"
alias python="python3"
alias pip="pip3"

# =============================================================================
# Completions
# =============================================================================
# Tab Completion Enhancements
zstyle ':completion:*' matcher-list 'm:{a-z1-9}={A-Z1-9}' # case-insensitive completion
zstyle ':completion:*' menu select                        # arrow keys to select from menu
zstyle ':completion:*:default' list-colors ''             # use terminal colors in menu

# Optimized compinit (full check only if dump is > 24h old)
# Array because glob qualifiers don't expand in [[ ]]; touch restarts the 24h window.
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

# Bash-style completion support (required for terraform)
if (( $+commands[terraform] )); then
  # Lazy-load completion on first Tab press to speed up shell startup
  _terraform_lazy_complete() {
    compdef -d terraform
    autoload -Uz bashcompinit && bashcompinit
    complete -o nospace -C "$commands[terraform]" terraform
    _normal
  }
  compdef _terraform_lazy_complete terraform
fi

# =============================================================================
# Integrations & Hooks
# =============================================================================

# Direnv (Static Hook); -U keeps hooks unique when this file is re-sourced
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

# Cached init scripts (avoid running the binary on every startup)
# Usage: _cached_init <command> <cache-name> <generator command...>
# Regenerates the cache when it is missing, empty, or older than the binary.
# The binary's own mtime is checked without following symlinks: Homebrew
# bottles keep their build time, but the bin/ symlink is recreated on upgrade.
zmodload -F zsh/stat b:zstat
_cached_init() {
  local cmd=$1 cache="${ZSH_CACHE_DIR:-$HOME/.cache}/zsh_$2"
  local -a bin_mtime cache_mtime
  shift 2
  (( $+commands[$cmd] )) || return
  # zstat -A stores into arrays, avoiding a fork per $(...) on startup.
  if [[ ! -s "$cache" ]] ||
     ! zstat -L -A bin_mtime +mtime -- "$commands[$cmd]" ||
     ! zstat -A cache_mtime +mtime -- "$cache" ||
     (( bin_mtime[1] > cache_mtime[1] )); then
    # Write via a temp file so a concurrently starting shell never sources a
    # partial cache; on failure the previous cache (if any) is kept.
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

_cached_init npm npm_completion npm completion # NPM completion
_cached_init fzf fzf fzf --zsh                 # FZF (key bindings & completion)
_cached_init zoxide zoxide zoxide init zsh     # Zoxide (smart directory jumper)
unfunction _cached_init

# Live Interactive Search (ripgrep + fzf)
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

  # Enter replaces fzf with the editor (become), so fzf's exit status is the
  # editor's after a selection and non-zero on cancel: the last command's
  # status is returned as-is for the Ctrl+F widget.
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

# Zsh Line Editor (ZLE) Widget for Ctrl+F
fif-widget() {
  zle -I
  fif "$BUFFER" && BUFFER=""
  zle -R
}
zle -N fif-widget
bindkey '^F' fif-widget

# fzf-git.sh (https://github.com/junegunn/fzf-git.sh)
[[ -f ~/fzf-git.sh ]] && source ~/fzf-git.sh

# =============================================================================
# Prompt & Git
# =============================================================================
# Optimized Git Prompt (Single-call Porcelain Status)
# Pure formatter; test/zshrc_git_prompt.zsh extracts it between the markers.
# >>> git-prompt-format
# Usage: _git_prompt_format <git status --branch --porcelain=v1 output>
_git_prompt_format() {
  GIT_PS1=""

  # Exit if not in a git repo
  [[ -z $1 ]] && return

  local -a lines
  lines=(${(f)1})

  # Parse Branch and Upstream from the first line (e.g., ## master...origin/master [ahead 1])
  local line1=$lines[1]
  local branch=${line1#\#\# }
  branch=${branch#No commits yet on }
  branch=${branch%%...*}

  local markers=""
  # Upstream status: match only the bracketed part (branch names may contain these words)
  if [[ "$line1" == *'['* ]]; then
    local upstream=${line1#*\[}
    [[ "$upstream" == *"behind"* ]] && markers+="<"
    [[ "$upstream" == *"ahead"* ]] && markers+=">"
    [[ "$upstream" == *"gone"* ]] && markers+="!"
  elif [[ "$line1" == *"..."* ]]; then
    markers+="="
  fi

  # Working tree status (lines 2 and beyond)
  local -a body
  body=("${(@)lines[2,-1]}")
  # Staged: First column is not space or ?
  (( ${#body[(r)[^ ?]*]} )) && markers+="+"
  # Dirty: Second column is not space or ?
  (( ${#body[(r)?[^ ?]*]} )) && markers+="*"
  # Untracked: Starts with ??
  (( ${#body[(r)\?\?*]} )) && markers+="?"

  # Escape % so the prompt doesn't expand it
  branch=${branch//\%/%%}
  GIT_PS1=" [$branch${markers:+ $markers}]"
}
# <<< git-prompt-format

_update_git_prompt() {
  # Single git call for all status info (branch, upstream, staged, dirty, untracked)
  # GIT_OPTIONAL_LOCKS=0: avoid index.lock contention with concurrent git commands
  _git_prompt_format "$(GIT_OPTIONAL_LOCKS=0 git status --branch --porcelain=v1 --untracked-files=normal 2>/dev/null)"
}

# Apply Prompt
precmd_functions+=(_update_git_prompt)

PS1='%c${GIT_PS1} $ '

# Print profile (see top)
if [[ -n $ZSH_PROFILE ]]; then
  zprof
fi
