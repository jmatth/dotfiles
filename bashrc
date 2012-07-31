#export statements
export EDITOR=vim
#export PS1='\[\e[0m\][\[\e[32;1m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\W\$\[\e[m\]] \[\e[1;37m\]'
export TERM='xterm-256color'

#program shortcuts
alias bashmod="vim ~/.bashrc"
alias bashsave="source ~/.bashrc"
alias vmod="vim ~/.vimrc"

#aliases for ls
alias ls="ls --color=auto -F"
alias la="ls -Alh"
alias ll="ls -lh"

#aliases for random ops
alias cc="clear"
alias bus="~/./bus"
alias hosts="vim /etc/hosts"
alias cgrep="grep --color=always"
alias ps1bw="export PS1='\[$NC\]\u@\h:\W\`nonzero_return\`\`parse_git_branch\`\\$ '"

#aliases for directory navigation
alias ..="cd .."
alias me="cd ~;ls"
alias dots="cd ~/dotfiles;ls"

#ssh aliases
alias ziti="ssh ziti.rutgers.edu"
alias ravioli='ssh ravioli.rutgers.edu'
alias sauron='ssh sauron.rutgers.edu'
alias eden='ssh eden.rutgers.edu'

#program settings variables
export GREP_OPTIONS='--color=auto'

#swap esc and capslock
function keyswap () {
	xmodmap -e 'keycode 66 = Caps_Lock' \
	-e 'keycode 9 = Escape' \
	-e 'remove Lock = Caps_Lock' \
	-e 'keycode 9 = Caps_Lock' \
	-e 'keycode 66 = Escape'
}

#autocomplete commnads
complete -cf sudo
complete -cf which
complete -cf man

#Start Russ Frank bashrc

[ -z "$PS1" ] && return # If not running interactively, don't do anything

HISTCONTROL=ignoreboth #ignore duplicate and leading whitespace commands in history

shopt -s histappend   # append to history file
shopt -s checkwinsize # ensure window size is correct

export CLICOLOR=true

function EXT_COL () { echo -ne "\033[38;5;$1;01m"; }

function ROOT_COL () {
	if id | cut -d' ' -f1 | grep -iq 'root'
	then
		if [ $2 ]
		then
			echo -ne "\033[38;5;1;05m";
		else
			echo -ne "\033[38;5;1;01m";
		fi
	else
		echo -ne "\033[38;5;$1;01m";
	fi
}

NC='\e[m'   # reset colors

USERCOL=`EXT_COL 27`
ATCOL=`EXT_COL 3`
HOSTCOL=`EXT_COL 34`
PATHCOL=`EXT_COL 45`
BRANCHCOL=`EXT_COL 220`
RETURNCOL=`EXT_COL 9`
TIMECOL=`EXT_COL 242`
PROMPTCOL=`ROOT_COL 7 b`

parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

function parse_git_dirty {
        status=`git status 2>&1 | tee`
        dirty=`echo -n "${status}" 2> /dev/null | grep -q "modified:" 2> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep -q "Untracked files" 2> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep -q "Your branch is ahead of" 2> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep -q "new file:" 2> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep -q "renamed:" 2> /dev/null; echo "$?"`
		  deleted=`echo -n "${status}" 2> /dev/null | grep -q "deleted:" 2> /dev/null; echo "$?"`
        bits=''
		  if [ "${deleted}" == "0" ]; then
					 bits="⊗${bits}"
		  fi
        if [ "${renamed}" == "0" ]; then
                bits=">${bits}"
        fi
        if [ "${ahead}" == "0" ]; then
                bits="*${bits}"
        fi
        if [ "${newfile}" == "0" ]; then
                bits="+${bits}"
        fi
        if [ "${untracked}" == "0" ]; then
                bits="?${bits}"
        fi
        if [ "${dirty}" == "0" ]; then
                bits="⚡${bits}"
        fi
        echo "${bits}"
}

nonzero_return() {
   RETVAL=$?
   [ $RETVAL -ne 0 ] && echo " ⏎$RETVAL "
}

#PS1="\n$TIMECOL\@ $USERCOL \u $ATCOL@ $HOSTCOL\h $PATHCOL \w $RETURNCOL\`nonzero_return\`$BRANCHCOL \`parse_git_branch\`\`parse_git_dirty\` $NC\n\\$ "

# One line w/ time
#PS1="\[$TIMECOL\]\@\[$USERCOL\]\u\[$ATCOL\]@\[$HOSTCOL\]\h\[$PATHCOL\]\W\[$RETURNCOL\]\`nonzero_return\`\[$BRANCHCOL\]\`parse_git_branch\`\`parse_git_dirty\`\[$PROMPTCOL\]\\$ \[$NC\]"

# One line w/o time
#PS1="\[$USERCOL\]\u\[$NC\]\[$ATCOL\]@\[$HOSTCOL\]\h\[$NC\]:\[$PATHCOL\]\W\[$RETURNCOL\]\`nonzero_return\`\[$BRANCHCOL\]\`parse_git_branch\`\`parse_git_dirty\`\[$PROMPTCOL\]\\$ \[$NC\]"
PS1="\[$USERCOL\]\u\[$NC\]\[$ATCOL\]@\[$HOSTCOL\]\h\[$NC\]:\[$PATHCOL\]\W\[$RETURNCOL\]\`nonzero_return\`\[$BRANCHCOL\]\`parse_git_branch\`\[$PROMPTCOL\]\\$ \[$NC\]"

#PS1="$USERCOL\u$ATCOL@$HOSTCOL\h$NC:$PATHCOL\W$RETURNCOL\`nonzero_return\`$BRANCHCOL\`parse_git_branch\`\`parse_git_dirty\`$ROOT_COL\\$ $NC"

#export PS1='\[\e[32;1m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\W $NC\$ '

if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

if [ -f ~/.bash_local ]; then
   . ~/.bash_local
fi

if [ -f ~/.nvm/nvm.sh ]; then
   . ~/.nvm/nvm.sh
fi
#end Russ Frank bashrc

# keyswap if possible
keyswap &> /dev/null

#print archey if installed
if ! which archey 2>&1 | grep -iq "no archey" && which archey &> /dev/null
then
	archey
fi

function up () {
	if [ "$#" -eq "0" ]
	then
		cd ../
	elif [ "$#" -gt "1" ]
	then
		echo "Usage: up [int]"
		return 2
	elif ! [[ "$1" =~ ^[0-9]+$ ]]
	then
		echo "Usage: up [int]"
		return 2
	else
		numdirs=""
		for i in `seq 1 $1`
		do
			numdirs="$numdirs../"
		done
		cd $numdirs
	fi
}
