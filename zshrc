## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## plugins
plugins+=(zsh-nvm)

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
ZSH_THEME="avit"
autoload -U colors
colors

# Pretty prompt
autoload -U colors && colors
#PS1="[%{$fg[red]%}%n%{$reset_color%}@%{$fg[cyan]%}`hostname | sed s/.amazon.com//`%{$reset_color%}:%{$fg[yellow]%}%d%{$reset_color%}]$(git_prompt_info)
#> "

# zsh completion lines
fpath=($fpath ~/gitclones/zsh-completions/src)
fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit && compinit -i

compinit

######################### Aliases ###################################
# Handle the fact that this file will be used with multiple OSs
 platform=`uname`
 if [[ $platform == 'Linux' ]]; then
     alias a='ls -lrth --color'
 elif [[ $platform == 'Darwin' ]]; then
     alias a='ls -lrthG'
 fi

## IDEs
#...

## Places
alias @cdw='cd $WORKPLACE'
alias cdw='@cdw'
alias @w='cd $WORKPLACE'
alias w='@w'
alias @dfd='cd $DOTFILES_HOME'
alias dfd='@dfd'

## Credential providers
#...

## Tools
alias egrep='egrep -i --color=auto'
alias epoch='date +%s'
alias gamf='git commit -am f'
alias gb='git branch'
alias gbackup='git push backup --force "refs/heads/*:refs/heads/*"'
alias gbls='git branch -vv'
alias gbu='echo "The upstream branch: $(git rev-parse --abbrev-ref --symbolic-full-name @{u})"' #print this branch's upstream branch
alias gc='git checkout'
alias glg='git log --graph --decorate --oneline $(git rev-parse --abbrev-ref --symbolic-full-name HEAD @{u})' #show the git DAG as a graph
alias glga='git log --graph --decorate --oneline --all' #show the git DAG as a graph
alias gpom='git push origin HEAD:mainline'
alias grep='grep -i --color=auto'
alias gri='git rebase -i'
alias grim='git rebase -i origin/mainline'
alias ivm='vim'
alias ll='ls -alh'
alias ls='ls -G'
alias prepl='perl -d -e 1'
alias v='vim $DOTFILES_HOME/vimrc'
alias vd='vim ./.'
alias vmi='vim'
alias z='vim $DOTFILES_HOME/zshrc'

###################### Functions ####################################

function forward_odin() {
    ssh -f -N -L 2009:127.0.0.1:2009 "$1"
}

# This gets the files that have changed on your local branch since you pushed to
# the upstream branch
function fupdiff() {
    echo "Getting the diff between this branch and its upstream branch. ($(git rev-parse --abbrev-ref=strict @{u})) \n\n\n...\n\n\n";
    git fetch
    git diff --name-only @{u}
    echo "\n"
}

# This gets the diff between the current branch and its upstream branch
function updiff() {
    echo "Getting the diff between this branch and its upstream branch. ($(git rev-parse --abbrev-ref --symbolic-full-name @{u})) \n\n\n...\n\n\n"; 
    git fetch
    git diff --ignore-all-space $(git rev-parse --abbrev-ref --symbolic-full-name @{u});
    echo "\n"
}

function wsupdiff () {
  dir=$(pwd)
  cd $dir
  for d in `find . -type d -maxdepth 1`
  do
    echo "\n#########################\n"
    cd $dir/$d
    pwd
    git fetch
    git status
    updiff
    cd ..
  done;

}

function wsgst() {
  dir=$(pwd)
  cd $dir
  for d in `find . -type d -maxdepth 1`
  do
    echo "\n#########################\n"
    cd $dir/$d
    pwd
    git fetch
    git status
    cd ..
  done;
}

# This allows you to query the dictionary for words that match a given regex
function wordbowl() {
    cat /usr/share/dict/words | grep "$1"
}

# kill processes by loose name
function appkill() {
    kill -9 $(ps -ef | grep $1 | grep -v grep | awk '{print $2}')
}

touch! () {
  touch $1
  if test $? -gt 0; then
    mkdir -p $(echo $1 | rev | cut -d '/' -f2- | rev)
    touch $1
  fi
}

gv2svg() {
     cat $1 | dot | gvpack | neato -n2 -Tpng > ./gv.svg
     echo "./gv.svg created"
}

######################### Env Variables #############################
export ANDROID_HOME=
export DOTFILES_HOME=
export JAVA_HOME=
export WORKPLACE=

######################### Path Exports ##############################
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH
export PATH=$HOME/bin/*:$PATH
#export PATH=$HOME/node_modules/.bin/:$PATH
export PATH=$PATH:/Users/$USER/usr/bin
export PATH=$PATH:/Applications/Sublime\ Text.app/Contents/SharedSupport/bin
# =============================================================================
# Initialize autocompletion for Homebrew packages
# =============================================================================
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

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

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

if [[ $platform == 'Linux' ]]; then
  if ! [[ $TERM == "screen" ]]
  then
      tmux attach
  fi
fi
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
  
source ~/.oh-my-zsh/oh-my-zsh.sh
