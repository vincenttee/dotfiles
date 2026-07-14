# =============================================================================
# Benchmarking (Enable this to profile startup)
# =============================================================================
# zmodload zsh/zprof

# =============================================================================
# Environment
# =============================================================================
# Most environment and path configuration is in .zshenv for better performance
# and to ensure availability in non-interactive shells.

# =============================================================================
# Options & History
# =============================================================================
setopt NONOMATCH
setopt PROMPT_SUBST
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
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
alias cht.sh=~/bin/cht.sh

# Usage: dedupeFile <input> <output>
dedupeFile() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: dedupeFile <input> <output>"
    return 1
  fi
  awk '!visited[$0]++' "$1" > "$2"
}

# =============================================================================
# Completions
# =============================================================================
# Tab Completion Enhancements
zstyle ':completion:*' matcher-list 'm:{a-z1-9}={A-Z1-9}' # case-insensitive completion
zstyle ':completion:*' menu select                        # arrow keys to select from menu
zstyle ':completion:*:default' list-colors ''             # use terminal colors in menu

# Optimized compinit (only runs full check if cache is > 24h old)
autoload -Uz compinit
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(N.m-1) ]]; then
  compinit -C
else
  compinit
fi

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

# Cached NPM completion
if type npm &>/dev/null; then
  NPM_COMP_CACHE="${ZSH_CACHE_DIR:-$HOME/.cache}/zsh_npm_completion"
  [[ -d "${NPM_COMP_CACHE:h}" ]] || mkdir -p "${NPM_COMP_CACHE:h}"
  if [[ ! -f "$NPM_COMP_CACHE" ]]; then
    npm completion > "$NPM_COMP_CACHE" 2>/dev/null
  fi
  [[ -f "$NPM_COMP_CACHE" ]] && source "$NPM_COMP_CACHE"
fi

# =============================================================================
# Integrations & Hooks
# =============================================================================

# Direnv (Static Hook)
if (( $+commands[direnv] )); then
  _direnv_hook() {
    trap -- '' SIGINT
    eval "$("direnv" export zsh)"
    trap - SIGINT
  }
  typeset -ag precmd_functions chpwd_functions
  [[ -z "${precmd_functions[(r)_direnv_hook]}" ]] && precmd_functions+=( _direnv_hook )
  [[ -z "${chpwd_functions[(r)_direnv_hook]}" ]] && chpwd_functions+=( _direnv_hook )
fi

# FZF (Cached script avoids binary execution on startup)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if type fzf &>/dev/null; then
  FZF_CACHE="${ZSH_CACHE_DIR:-$HOME/.cache}/zsh_fzf"
  [[ -d "${FZF_CACHE:h}" ]] || mkdir -p "${FZF_CACHE:h}"
  if [[ ! -f "$FZF_CACHE" ]]; then
    fzf --zsh > "$FZF_CACHE" 2>/dev/null
  fi
  [[ -f "$FZF_CACHE" ]] && source "$FZF_CACHE"
fi

# Live Interactive Search (ripgrep + fzf)
fif() {
  if ! type rg &>/dev/null; then
    echo "fif: 'rg' (ripgrep) not found."
    return 1
  fi
  if ! type fzf &>/dev/null; then
    echo "fif: 'fzf' not found."
    return 1
  fi

  local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
  local INITIAL_QUERY="${*:-}"
  local selection
  local preview_cmd='cat {1}'

  if type bat &>/dev/null; then
    preview_cmd='bat --paging=never --theme=gruvbox --color=always --style=numbers {1} --highlight-line {2}'
  fi

  selection=$(FZF_DEFAULT_COMMAND="$RG_PREFIX -- $(printf %q "$INITIAL_QUERY")" \
    fzf --ansi \
    --disabled --query "$INITIAL_QUERY" \
    --bind "change:reload:$RG_PREFIX -- {q} || true" \
    --delimiter : \
    --preview "$preview_cmd" \
    --preview-window 'right:60%,border-left,+{2}-5' \
    --prompt 'Search Content: ' \
    --header 'Press Enter to open in Vim | ESC to cancel')

  if [[ -n "$selection" ]]; then
    local file line
    file=$(echo "$selection" | cut -d: -f1)
    line=$(echo "$selection" | cut -d: -f2)
    ${EDITOR:-vim} "$file" "+$line" < /dev/tty
    return 0
  fi
  return 1
}

# Zsh Line Editor (ZLE) Widget for Ctrl+F
fif-widget() {
  zle -I
  if fif "$BUFFER"; then
    BUFFER=""
  fi
  zle -R
}
zle -N fif-widget
bindkey '^F' fif-widget

# fzf-git.sh (https://github.com/junegunn/fzf-git.sh)
[ -f ~/fzf-git.sh ] && source ~/fzf-git.sh

# =============================================================================
# Prompt & Git
# =============================================================================
# Optimized Git Prompt (Single-call Porcelain Status)
_update_git_prompt() {
  GIT_PS1=""
  # Single git call for all status info (branch, upstream, staged, dirty, untracked)
  local status_out
  status_out=$(git status --branch --porcelain=v1 --untracked-files=normal 2>/dev/null)

  # Exit if not in a git repo
  if [[ -z "$status_out" ]]; then
    return
  fi

  local -a lines
  lines=(${(f)status_out})

  # Parse Branch and Upstream from the first line (e.g., ## master...origin/master [ahead 1])
  local line1=$lines[1]
  local branch_tmp=${line1#\#\# }
  local branch=${branch_tmp%%...*}

  local markers=""
  # Upstream status
  if [[ "$line1" == *'['* ]]; then
    [[ "$line1" == *"ahead"* ]] && markers+=">"
    [[ "$line1" == *"behind"* ]] && markers+="<"
    [[ "$markers" == "><" ]] && markers="<>"
    [[ "$line1" == *"gone"* ]] && markers+="!"
  elif [[ "$line1" == *"..."* ]]; then
    markers+="="
  fi

  # Working tree status (lines 2 and beyond)
  if (( ${#lines} > 1 )); then
    local -a body
    body=("${(@)lines[2,-1]}")
    # Staged: First column is not space or ?
    (( ${#body[(r)[^ ?]*]} )) && markers+="+"
    # Dirty: Second column is not space or ?
    (( ${#body[(r)?[^ ?]*]} )) && markers+="*"
    # Untracked: Starts with ??
    (( ${#body[(r)\?\?*]} )) && markers+="?"
  fi

  # Format output
  if [[ -n "$markers" ]]; then
    GIT_PS1=" [$branch $markers]"
  else
    GIT_PS1=" [$branch]"
  fi
}

# Apply Prompt
typeset -gU precmd_functions
precmd_functions+=(_update_git_prompt)

export PS1='%c${GIT_PS1} $ '

# Final profiler check (uncomment zmodload at top to use)
if command -v zprof >/dev/null; then
  zprof
fi