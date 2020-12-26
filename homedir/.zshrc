set -o magicequalsubst
export CONFIG_DIR='$HOME/.config'
export DOTFILES_HOME=$CONFIG_DIR/dotfiles
export ZSH=$DOTFILES_HOME/zsh
source $CONFIG_DIR/zsh/pre-compinit-scripts
source $CONFIG_DIR/zsh/oh-my-zsh.cfg
source $DOTFILES_HOME/zshrc
source $DOTFILES_HOME/environment_variables
source $DOTFILES_HOME/functions
source $DOTFILES_HOME/aliases
source $DOTFILES_HOME/path
source $DOTFILES_HOME/init_scripts
