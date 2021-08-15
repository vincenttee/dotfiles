# Development
. ~/.developmentrc

# Global
export EDITOR=vim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER="less -x4"
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export TERM=screen-256color

# History
export HISTFILESIZE=5000
export HISTSIZE=5000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT='%F %T '
export PROMPT_COMMAND='history -a'

# Git
export GIT_EDITOR=vim
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=

# Go
export GOPATH=/Users/$USER/go
export PATH=$GOPATH/bin:$PATH

# FZF
# https://minsw.github.io/fzf-color-picker/
export FZF_DEFAULT_OPTS='--height 40% --border
--color=fg:#e5dbc4,bg:-1,hl:#d69e49
--color=fg+:#b8af9a,bg+:#262626,hl+:#f0a327
--color=info:#b5a172,prompt:#ffa727,pointer:#ffa727
--color=marker:#cc4b5f,spinner:#d18822,header:#cc4b5f'
