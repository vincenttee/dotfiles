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

# History File (Zsh specific)
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
