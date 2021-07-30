set -o vi
export CONFIG_DIR=~/.config
export DOTFILES_HOME=$CONFIG_DIR/dotfiles
source $DOTFILES_HOME/environment_variables
source $DOTFILES_HOME/path
source $DOTFILES_HOME/aliases
source $DOTFILES_HOME/functions
[ -f $CONFIG_DIR/fzf/.fzf.bash ] && source $CONFIG_DIR/fzf/.fzf.bash
bind -f $HOME/.inputrc
shopt -s autocd
complete  -C aws_completer aws
