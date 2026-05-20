# Development
[ -f ~/.developmentrc ] && . ~/.developmentrc

# Zsh Path Optimization (Ensures unique entries in $PATH)
typeset -U path

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

# FZF Configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 40% --border
--color=fg:#e5dbc4,bg:-1,hl:#d69e49
--color=fg+:#b8af9a,bg+:#262626,hl+:#f0a327
--color=info:#b5a172,prompt:#ffa727,pointer:#ffa727
--color=marker:#cc4b5f,spinner:#d18822,header:#cc4b5f'

# History File (Zsh specific)
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
