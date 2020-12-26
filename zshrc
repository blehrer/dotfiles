## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## history
setopt APPEND_HISTORY
## for sharing history between zsh processes
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
# tab completion
setopt COMPLETE_IN_WORD
# never ever beep ever
setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
#MAILCHECK=0
autoload -U colors && colors

autoload -Uz compinit && compinit -i

######################### key bindings ###############################
# use vim bindings
bindkey -v

bindkey "^R" history-incremental-search-backward
bindkey "^E" end-of-line
bindkey "^A" beginning-of-line

#AWESOME...
#pushes current command on command stack and gives blank line, after that line
#runs command stack is popped
bindkey "^T" push-line-or-edit

######################### completion #################################

if [[ $platform == 'Darwin' ]]; then
  # these are some (mostly) sane defaults, if you want your own settings, I
  # recommend using compinstall to choose them.  See 'man zshcompsys' for more
  # info about this stuff.
  
  # The following lines were added by compinstall
  
  zstyle ':completion:*' completer _expand _complete _approximate
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
  zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
  zstyle ':completion:*' menu select=long
  zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
  zstyle ':completion:*' use-compctl true
  autoload -U compinit
fi

