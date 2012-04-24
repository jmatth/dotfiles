#export statements
export EDITOR=vim
#export PS1="[\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\W\[\e[00m\]]\$ "
export PS1='\[\e[0m\][\[\e[32;1m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\W\[\e[00m\]\$\[\e[m\]] \[\e[1;37m\]'
export TERM='xterm-256color'

#Sync config files:
(
	sleep 5m
	cd ~/rc-Files
	git pull -q
	exit
)& disown

#program shortcuts
alias fire="firefox"
alias bashmod="vim ~/.bashrc"
alias bashsave="source ~/.bashrc"
alias vmod="vim ~/.vimrc"

#aliases for ls
alias ls="ls --color=auto"
alias lsd="ls --color=always -alh | grep ^d"
alias lf="ls --color=always -lh | grep ^d"
alias l="ls"
alias s="l"
alias la="ls -Alh"
alias ll="ls -lh"

#aliases for random ops
alias cc="clear"
alias bus="~/./bus"
alias hosts="vim /etc/hosts"

#aliases for directory navigation
alias ..="cd .."
alias vi="vim"
alias v="vim"
alias me="cd ~;ls"

#ssh aliases
alias ziti="ssh ziti.rutgers.edu"
alias ravioli='ssh ravioli.rutgers.edu'
alias sauron='ssh sauron.rutgers.edu'
alias eden='ssh eden.rutgers.edu'
alias wol='ssh ravioli.rutgers.edu wol.sh'

#program settings variables
export GREP_OPTIONS='--color=auto'

#autocomplete commnads
complete -cf sudo
complete -cf which
complete -cf man
