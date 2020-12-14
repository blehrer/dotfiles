set -o magicequalsubst
export DOTFILES_HOME='/Users/BrianLehrer/.config/dotfiles'
export ZSH=$DOTFILES_HOME/zsh
source $DOTFILES_HOME/zsh/pre-compinit-scripts
source $DOTFILES_HOME/zsh/oh-my-zsh.cfg
source $DOTFILES_HOME/zshrc
source $DOTFILES_HOME/environment_variables
source $DOTFILES_HOME/functions
source $DOTFILES_HOME/aliases
source $DOTFILES_HOME/path
source $DOTFILES_HOME/init_scripts
