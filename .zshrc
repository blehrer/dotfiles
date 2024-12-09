# {{{: setopt imperatives
setopt append_history
setopt inc_append_history
setopt share_history
setopt complete_in_word
setopt no_beep
setopt autocd
setopt autopushd
setopt pushdsilent
setopt pushdignoredups
setopt nomailwarning
# }}}

# {{{: keybindings
bindkey -v
bindkey "^R" history-incremental-search-backward
bindkey "^E" end-of-line
bindkey "^A" beginning-of-line
bindkey "^N" push-line-or-edit
# }}}

# {{{: autoloads
autoload -U colors && colors
autoload sticky-note
# }}}

# {{{: completion
# {{{: my old stuff
######################### completion #################################
# zstyle ':completion:*' completer _expand _complete _approximate
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
# zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
# zstyle ':completion:*' menu select=long
# zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
# zstyle ':completion:*' use-compctl true
# fpath+=('~/.local/share/zsh/site-functions')
# autoload -Uz compinit && compinit -i
# }}}

#{{{: from https://github.com/Phantas0s/.dotfiles/blob/master/zsh/completion.zsh

# ____ ___  __  __ ____  _     _____ _____ ___ ___  _   _ 
#  / ___/ _ \|  \/  |  _ \| |   | ____|_   _|_ _/ _ \| \ | |
# | |  | | | | |\/| | |_) | |   |  _|   | |  | | | | |  \| |
# | |__| |_| | |  | |  __/| |___| |___  | |  | | |_| | |\  |
#  \____\___/|_|  |_|_|   |_____|_____| |_| |___\___/|_| \_|
 #

# +---------+
# | General |
# +---------+

# source ./gambit.zsh

# Load more completions
fpath=(~/.local/share/zsh/site-functions $fpath)

# Should be called before compinit
zmodload zsh/complist

# Use hjlk in menu selection (during completion)
# Doesn't work well with interactive mode
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'l' vi-forward-char

bindkey -M menuselect '^xg' clear-screen
bindkey -M menuselect '^xi' vi-insert                      # Insert
bindkey -M menuselect '^xh' accept-and-hold                # Hold
bindkey -M menuselect '^xn' accept-and-infer-next-history  # Next
bindkey -M menuselect '^xu' undo                           # Undo

autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files

# Only work with the Zsh function vman
# See $DOTFILES/zsh/scripts.zsh
compdef vman="man"

# +---------+
# | Options |
# +---------+

# setopt GLOB_COMPLETE      # Show autocompletion menu with globs
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.

# +---------+
# | zstyles |
# +---------+

# Ztyle pattern
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# Define completers
zstyle ':completion:*' completer _extensions _complete _approximate

# Use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-~/.cache}/zsh/.zcompcache"
# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true

zle -C alias-expension complete-word _generic
bindkey '^Xa' alias-expension
zstyle ':completion:alias-expension:*' completer _expand_alias

# Use cache for commands which use it

# Allow you to select in a menu
zstyle ':completion:*' menu select

# Autocomplete options for cd instead of directory stack
zstyle ':completion:*' complete-options true

zstyle ':completion:*' file-sort modification


zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# zstyle ':completion:*:default' list-prompt '%S%M matches%s'
# Colors for files and directory
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

# Only display some tags for the command cd
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
# zstyle ':completion:*:complete:git:argument-1:' tag-order !aliases

# Required for completion to be in good groups (named after the tags)
zstyle ':completion:*' group-name ''

zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# See ZSHCOMPWID "completion matching control"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' keep-prefix true

zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# }}}
# }}}

# {{{: plugins
for plugin in ~/.config/zsh/custom/plugins/*/*.plugin.zsh; do source $plugin; done
# }}}

#{{{: Tools
eval "$(mise activate zsh)"
export EDITOR=nvim
eval "$(starship init zsh)"
eval "$(thefuck --alias)"
source <(fzf --zsh)
#}}}

#{{{: Overrides
alias vim=nvim
alias ivm=nvim
alias vimdiff='nvim -d'
alias cz=chezmoi
alias l=eza
alias ll='l --long --all'
alias tree='l --tree --ignore-glob ".git/*|node_modules/*"'
alias mkdir='mkdir -p'
alias fzf="fzf --preview 'file {}' --bind '?:preview:bat {}'"
[ $(command -v fdfind) ] && alias fd=fdfind
alias lg=lazygit
#}}}

#{{{: Locations
alias dfd="chezmoi cd"
alias vd='nvim -c "Neotree"'
# }}}

#{{{: Git conveniences
function gamf (){ git commit -a --fixup "${@:-@}" }
alias gb='git branch'
alias gbls="git branch -vv | egrep -v '^\s*(ABANDONED|DONE)'"
alias gbu='echo "The upstream branch: $(git rev-parse --abbrev-ref --symbolic-full-name @{u})"'
alias gc='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias glg='git log --graph --tags --decorate --oneline $(git rev-parse --abbrev-ref --symbolic-full-name HEAD @{u})'
alias glga='git log --graph --decorate --oneline --all'
alias gri='git rebase -i'
alias gria='git rebase -i --autosquash'
alias garia='gamf; gria'
alias grim='git rebase -i origin/master'
alias gst='git status'
#}}}

#{{{: Java conveniences
gw () {
    local tld=$(git rev-parse --show-toplevel)
    eq=$(test $(pwd) = "${tld}")
    "${eq}" || pushd "${tld}"
    ./gradlew $@
    "${eq}" || popd
}
#}}}

# {{{: Command History
hgrep() {
  fc -Dlim "*$@*" 1
}

# }}} 

# {{{: Text Search
function fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" |
  fzf --preview "highlight -O ansi -l {} 2> /dev/null | \
  rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || \
  rg --ignore-case --pretty --context 10 '$1' {}"
}
# }}} 

# {{{: PATH
export PATH="~/.local/bin:${PATH}"
# }}} 

# {{{: Project aliases
function res {
	local input=$1 
	local dest=~/code/github.com/blehrer/resonance
	[ $input ] && cd $dest/$input || cd $dest
}
# }}} 

# vim: ts=2 sts=2 sw=2 et foldmethod=marker
