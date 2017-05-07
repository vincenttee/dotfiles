# Global
export EDITOR=vim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER="less -x4"
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export TERM=screen-256color

# Development
. ~/.developmentrc

# FZF
export FZF_DEFAULT_OPTS='--height 40% --border'

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
