if [[ -z "$INTELLIJ_ENVIRONMENT_READER" ]]; then
# bootstrap variables

export CONFIG_DIR=$HOME/.config

export XDG_CONFIG_HOME=$HOME/.config
export DOTFILES_HOME=$HOME/github.com/blehrer/dotfiles.git
export ADOTDIR=$CONFIG_DIR/zsh/antigen

# setup antigen zsh modules
source $ADOTDIR/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-completions
antigen theme avit
antigen apply



for i in $DOTFILES_HOME/shellenv/*; do source $i ; done
autoload -U colors && colors
autoload sticky-note

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# options
setopt auto_cd
setopt prompt_subst
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
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

# external resources
#zcfg=~/.config/zsh
#source $zcfg/git.zsh
#source $zcfg/theme-and-appearance.zsh
#source $zcfg/lib/spectrum.zsh
#source $zcfg/completion.zsh
#source $zcfg/git-prompt.sh
#source $zcfg/aws.plugin.zsh
#source $zcfg/avit.zsh-theme
#source $zcfg/mvn.plugin.zsh

         #$DOTFILES_HOME/bin/xit \
for i in $DOTFILES_HOME/environment_variables \
         $DOTFILES_HOME/path \
         $DOTFILES_HOME/zshrc \
         $DOTFILES_HOME/bin/scriptbucket \
         $DOTFILES_HOME/bin/explain \
         $DOTFILES_HOME/aliases \
         ${HOME}/.cargo/env \
         $DOTFILES_HOME/init_scripts; do
    #echo "=========== sourcing $i ==============="
    #timer=$(($($HOMEBREW_REPOSITORY/bin/gdate +%s%N)/1000000))
    source $i
    #now=$(($($HOMEBREW_REPOSITORY/bin/gdate +%s%N)/1000000))
    #elapsed=$(($now-$timer))
    #echo $elapsed":" $i
    #echo "========== done sourcing $i =============="
done
source $VIM_PLUGINS/gruvbox/gruvbox_256palette.sh

# bash completions
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
compinit
complete -C $(which aws_completer) aws
#source $DOTFILES_HOME/lib/completions/xit-completion.bash

compdef cf=git

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(starship init zsh)"


fpath=(~/.zsh.d/ $fpath)

# if you dont do this, the quote/double-quote key does int'l stuff
setxkbmap us
# sets the relative position of the external monitor (HDMI-1) to the laptop monitor (eDP-1)
xrandr --output HDMI-1 --above eDP-1

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

## close [[ -z $INTELLIJ_ENVIRONMENT_READER ]] condition
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
