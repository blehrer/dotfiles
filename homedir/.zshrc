set -o magicequalsubst
export CONFIG_DIR=$HOME/.config
export DOTFILES_HOME=$CONFIG_DIR/dotfiles
export ZSH=$DOTFILES_HOME/gitclones/oh-my-zsh
source $HOME/.vim/pack/vendor/start/gruvbox/gruvbox_256palette.sh
source $DOTFILES_HOME/environment_variables
source $DOTFILES_HOME/path
source $DOTFILES_HOME/zsh/pre-compinit-scripts
source $DOTFILES_HOME/zsh/oh-my-zsh.cfg
source $DOTFILES_HOME/zshrc
source $DOTFILES_HOME/functions
source $DOTFILES_HOME/aliases
source $DOTFILES_HOME/init_scripts

