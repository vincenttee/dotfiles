# =============================================================================
# Environment & Homebrew
# =============================================================================
# Initialize Homebrew based on architecture
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/bin:/usr/local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# =============================================================================
# Options & History
# =============================================================================
setopt NONOMATCH
setopt PROMPT_SUBST
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

# Add Homebrew completions to FPATH
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Optimized compinit (only runs if cache is > 24h old)
autoload -Uz compinit
for dump in "${ZDOTDIR:-$HOME}/.zcompdump"(N.m-1); do
  compinit
  break
done
[[ -z "$dump" ]] && compinit -C

# Simplified NPM completion
if type npm &>/dev/null; then
  source <(npm completion)
fi

# =============================================================================
# Integrations
# =============================================================================
# Direnv
if type direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if type fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# fzf-git.sh (https://github.com/junegunn/fzf-git.sh)
[ -f ~/fzf-git.sh ] && source ~/fzf-git.sh

# FZF Options
export FZF_DEFAULT_OPTS='--height 40% --border
--color=fg:#e5dbc4,bg:-1,hl:#d69e49
--color=fg+:#b8af9a,bg+:#262626,hl+:#f0a327
--color=info:#b5a172,prompt:#ffa727,pointer:#ffa727
--color=marker:#cc4b5f,spinner:#d18822,header:#cc4b5f'

# Git Prompt Options
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=

# Git Prompt
[ -f ~/.git-prompt.sh ] && source ~/.git-prompt.sh
export PS1='%c$(__git_ps1 " [%s]") $ '

# NVM (Node Version Manager)
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
  [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
fi
