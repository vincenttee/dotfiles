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
  [[ -d "${cache:h}" ]] || mkdir -p "${cache:h}"
  # zstat -A stores into arrays, avoiding a fork per $(...) on startup.
  if [[ ! -s "$cache" ]] ||
     ! zstat -L -A bin_mtime +mtime -- "$commands[$cmd]" ||
     ! zstat -A cache_mtime +mtime -- "$cache" ||
     (( bin_mtime[1] > cache_mtime[1] )); then
    # Write via a temp file so a concurrently starting shell never sources a
    # partial cache; on failure the previous cache (if any) is kept.
    local tmp="$cache.$$"
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
  if ! type rg &>/dev/null; then
    echo "fif: 'rg' (ripgrep) not found."
    return 1
  fi
  if ! type fzf &>/dev/null; then
    echo "fif: 'fzf' not found."
    return 1
  fi

  local RG_PREFIX="rg --column --line-number --no-heading --color=always"
  local INITIAL_QUERY="${*:-}"
  local preview_cmd='cat {1}'

  if type bat &>/dev/null; then
    preview_cmd='bat --paging=never --color=always --style=numbers {1} --highlight-line {2}'
  fi

  # Enter replaces fzf with the editor (become), so fzf's exit status is the
  # editor's after a selection and non-zero on cancel: the last command's
  # status is returned as-is for the Ctrl+F widget.
  fzf --ansi \
    --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload:$RG_PREFIX -- {q} || true" \
    --bind "change:reload:$RG_PREFIX -- {q} || true" \
    --bind "enter:become(${EDITOR:-vim} {1} +{2})" \
    --delimiter : \
    --preview "$preview_cmd" \
    --preview-window 'right:60%,border-left,+{2}-5' \
    --prompt 'Search Content: ' \
    --header "Press Enter to open in ${EDITOR:-vim} | ESC to cancel"
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
