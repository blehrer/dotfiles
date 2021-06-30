autoload -U colors && colors
autoload sticky-note

# The following lines were added by compinstall
zstyle :compinstall filename '/home/206672215/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# options
setopt auto_cd
setopt prompt_subst
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt COMPLETE_IN_WORD
setopt NO_BEEP

# keybindings
bindkey -v
bindkey "^R" history-incremental-search-backward
bindkey "^E" end-of-line
bindkey "^A" beginning-of-line
bindkey "^T" push-line-or-edit

#AWESOME...
#pushes current command on command stack and gives blank line, after that line
#runs command stack is popped
bindkey "^T" push-line-or-edit

# bootstrap variables
export CONFIG_DIR=$HOME/.config
export DOTFILES_HOME=$CONFIG_DIR/dotfiles

# external resources
zcfg=~/.config/zsh
source $zcfg/git.zsh
source $zcfg/theme-and-appearance.zsh
source $zcfg/lib/spectrum.zsh
source $zcfg/completion.zsh
source $zcfg/git-prompt.sh
source $zcfg/aws.plugin.zsh
source $zcfg/avit.zsh-theme

for i in $DOTFILES_HOME/environment_variables \
         $DOTFILES_HOME/path \
         $DOTFILES_HOME/zshrc \
         $DOTFILES_HOME/bin/scriptbucket \
         $DOTFILES_HOME/aliases \
         $DOTFILES_HOME/init_scripts; do
#    timer=$(($(/usr/local/homebrew/bin/gdate +%s%N)/1000000))
    source $i
#    now=$(($(/usr/local/homebrew/bin/gdate +%s%N)/1000000))
#    elapsed=$(($now-$timer))
#    echo $elapsed":" $i
done
source $VIM_PLUGINS/gruvbox/gruvbox_256palette.sh

# bash completions
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
compinit
complete -C '/usr/local/bin/aws_completer' aws
