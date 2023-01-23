# bootstrap variables

export CONFIG_DIR=$HOME/.config
export XDG_CONFIG_HOME=$HOME/.config
export DOTFILES_HOME=$HOME/github.com/blehrer/dotfiles.git
for i in $DOTFILES_HOME/shellenv/*; do source $i ; done
#source $HOMEBREW_PREFIX/share/antigen/antigen.zsh
#antigen init ~/.antigenrc
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
export DOTFILES_HOME=$HOME/github.com/blehrer/dotfiles.git

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
         $HOME/.secret_variables_nbcu \
         $DOTFILES_HOME/path \
         $DOTFILES_HOME/zshrc \
         $DOTFILES_HOME/bin/scriptbucket \
         $DOTFILES_HOME/aliases \
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

export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_REPOSITORY/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_REPOSITORY/opt/nvm/nvm.sh"  # This loads nvm
[ -s "$HOMEBREW_REPOSITORY/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_REPOSITORY/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


PATH="/Users/a206672215/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/a206672215/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/a206672215/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/a206672215/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/a206672215/perl5"; export PERL_MM_OPT;


neofetch
eval "$(starship init zsh)"
source $OTS/xit.git/.env
