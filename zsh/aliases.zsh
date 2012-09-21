# aliases.zsh: Sets up aliases which make working at the command line easier.

#program shortcuts
alias zmod="vim ~/.zsh"
alias zsave="source ~/.zshrc"
alias vmod="vim ~/.vimrc"
alias sudo="sudo -E"

#aliases for ls
alias ls="ls --color=auto -F"
alias la="ls -Alh"
alias lsa="ls -A"

#aliases for random ops
alias hosts="vim /etc/hosts"
alias cgrep="grep --color=always"

#aliases for directory navigation
alias ..="cd .."
alias me="cd ~;ls"
alias dots="cd ~/dotfiles;ls"
alias gitroot='cd $(git rev-parse --show-toplevel)'

#ssh aliases
alias assembly="ssh assembly.rutgers.edu"
alias sauron='ssh sauron.rutgers.edu'
alias eden='ssh eden.rutgers.edu'

# The many forms of zmv.
alias zmv="zmv -wM"
alias zcp="zmv -wC"
alias zln="zmv -wL"

#alias ...=../..

# Some application shortcuts.
#alias b="sudo -E bauerbill"
#alias g="grep -EiRn --color=tty"
#alias m="mplayer"
#alias o="okular"

# Start a Vim Server, I'm told it's useful.
#alias vim='vim --servername $(date +"%Y-%m-%D/%H:%M:%S")'

# Not exactly an alias, but a workaround for completion's sake.
#which hub > /dev/null; (( 1 - $? )) && function git() { hub "$@" }
