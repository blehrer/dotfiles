set -o vi
export CONFIG_DIR=~/.config
export DOTFILES_HOME=$CONFIG_DIR/dotfiles
source $DOTFILES_HOME/environment_variables
source $DOTFILES_HOME/path
source $DOTFILES_HOME/aliases
source $DOTFILES_HOME/bin/scriptbucket
bind -f $HOME/.inputrc
shopt -s autocd
complete  -C aws_completer aws
