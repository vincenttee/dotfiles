# Development
[ -f ~/.developmentrc ] && . ~/.developmentrc

# Zsh Path Optimization (Ensures unique entries)
typeset -U path fpath manpath infopath

# Homebrew Environment
# Hardcoded for speed (avoids calling 'brew shellenv' which is slow)
if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d /usr/local/Homebrew ]]; then
  export HOMEBREW_PREFIX="/usr/local"
fi

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
  path=(
    $HOMEBREW_PREFIX/bin
    $HOMEBREW_PREFIX/sbin
    $path
  )
  manpath=(
    $HOMEBREW_PREFIX/share/man
    $manpath
  )
  infopath=(
    $HOMEBREW_PREFIX/share/info
    $infopath
  )
  fpath=(
    $HOMEBREW_PREFIX/share/zsh/site-functions
    $fpath
  )
fi

# Global Environment
export EDITOR=vim
export GIT_EDITOR=vim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER="less -x4"

# Path Configuration
path=(
  $HOME/bin
  /usr/local/bin
  /usr/local/sbin
  $path
)

# Go Environment
export GOPATH=$HOME/go
path=($GOPATH/bin $path)

# Export path to subshells
export PATH

# Ripgrep Configuration
[[ -f "$HOME/.ripgreprc" ]] && export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# Bat Configuration
export BAT_THEME="gruvbox-dark"

# FZF Configuration
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --border
--color=fg:#e5dbc4,bg:-1,hl:#d69e49
--color=fg+:#b8af9a,bg+:#262626,hl+:#f0a327
--color=info:#b5a172,prompt:#ffa727,pointer:#ffa727
--color=marker:#cc4b5f,spinner:#d18822,header:#cc4b5f'
export FZF_CTRL_R_OPTS="--tiebreak=index"

# History File (Zsh specific)
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
