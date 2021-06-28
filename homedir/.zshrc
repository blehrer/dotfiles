set -o magicequalsubst
export CONFIG_DIR=$HOME/.config
export DOTFILES_HOME=$CONFIG_DIR/dotfiles

for i in $DOTFILES_HOME/environment_variables \
         $DOTFILES_HOME/path \
         $DOTFILES_HOME/zsh/pre-compinit-scripts \
         $DOTFILES_HOME/zsh/oh-my-zsh.cfg \
         $DOTFILES_HOME/zshrc \
         $DOTFILES_HOME/functions \
         $DOTFILES_HOME/aliases \
         $DOTFILES_HOME/init_scripts; do
#    timer=$(($(/usr/local/homebrew/bin/gdate +%s%N)/1000000))
    source $i
#    now=$(($(/usr/local/homebrew/bin/gdate +%s%N)/1000000))
#    elapsed=$(($now-$timer))
#    echo $elapsed":" $i
done
source $VIM_PLUGINS/gruvbox/gruvbox_256palette.sh
