# Global
export EDITOR=vim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER="less -x4"
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export TERM=screen-256color

# History
shopt -s histappend
shopt -s cmdhist
export HISTFILESIZE=5000
export HISTSIZE=5000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT='%F %T '
export PROMPT_COMMAND='history -a'

# Development
. ~/.developmentrc

# FZF
export FZF_DEFAULT_OPTS='--height 40% --border
--color=fg:#e5dbc4,bg:-1,hl:#d69e49
--color=fg+:#b8af9a,bg+:#262626,hl+:#f0a327
--color=info:#b5a172,prompt:#ffa727,pointer:#ffa727
--color=marker:#cc4b5f,spinner:#d18822,header:#cc4b5f'
# https://minsw.github.io/fzf-color-picker/

# Git
export GIT_EDITOR=vim
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export PS1='\W$(__git_ps1 " [%s]") $ '

# Go
export GOPATH=/Users/$USER/go
export PATH=$GOPATH/bin:$PATH

# Alias
alias ls="ls -G"
alias lsp="ls -lhtrF"
alias python=/usr/local/bin/python3
alias pip=/usr/local/bin/pip3

# Functions
dedupeFile() {
  awk '!visited[$0]++' $1 > $2;
};

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# NPM completion
source /usr/local/lib/node_modules/npm/lib/utils/completion.sh

# Direnv
_direnv_hook() {
  local previous_exit_status=$?;
  eval "$(direnv export bash)";
  return $previous_exit_status;
};
if ! [[ "$PROMPT_COMMAND" =~ _direnv_hook ]]; then
  PROMPT_COMMAND="_direnv_hook;$PROMPT_COMMAND";
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
