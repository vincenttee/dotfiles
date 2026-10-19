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
    $HOMEBREW_PREFIX/opt/ruby/bin
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
[[ -f "$HOME/.fzfrc" ]] && export FZF_DEFAULT_OPTS_FILE="$HOME/.fzfrc"

# History File (Zsh specific)
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
