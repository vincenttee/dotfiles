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

# Direnv (Static Hook avoids binary execution on startup)
if type direnv &>/dev/null; then
  _direnv_hook() {
    trap -- '' SIGINT;
    eval "$("direnv" export zsh)";
    trap - SIGINT;
  }
  typeset -ag precmd_functions;
  if [[ -z "${precmd_functions[(r)_direnv_hook]}" ]]; then
    precmd_functions=( _direnv_hook ${precmd_functions[@]} )
  fi
  typeset -ag chpwd_functions;
  if [[ -z "${chpwd_functions[(r)_direnv_hook]}" ]]; then
    chpwd_functions=( _direnv_hook ${chpwd_functions[@]} )
  fi
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
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=

# Git Prompt
[ -f ~/.git-prompt.sh ] && source ~/.git-prompt.sh
export PS1='%c$(__git_ps1 " [%s]") $ '

# Final profiler check (uncomment zmodload at top to use)
if command -v zprof >/dev/null; then
  zprof
fi

