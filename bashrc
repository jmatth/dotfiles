# If not running interactively, don't do anything
[ -z "$PS1" ] && return 

#export statements
export EDITOR=vim
export TERM='xterm-256color'
export CLICOLOR=true

#ignore duplicate and leading whitespace commands in history
HISTCONTROL=ignoreboth

shopt -s histappend      # append to history file
shopt -s checkwinsize    # ensure window size is correct
set -o vi                #vi mode shortcuts
bind "\C-l":clear-screen #still use control-l to clear screen.

#program shortcuts
alias bashsave="source ~/.bashrc"
alias vmod="vim ~/.vimrc"
alias sudo="sudo -E"

#aliases for ls
alias ls="ls --color=auto -F"
alias la="ls -Alh"
alias lsa="ls -A"

#aliases for random ops
alias bus="~/./bus"
alias hosts="vim /etc/hosts"
alias cgrep="grep --color=always"
alias ps1bw="export PS1='\[$NC\]\u@\h:\W\`nonzero_return\`\`parse_git_branch\`\\$ '"

#aliases for directory navigation
alias ..="cd .."
alias me="cd ~;ls"
alias dots="cd ~/dotfiles;ls"
alias gitroot='cd $(git rev-parse --show-toplevel)'

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
complete -c which

#256 color codes
function EXT_COL () { echo -ne "\[\033[38;5;$1;01m\]"; }

#16 color codes
function SIMPLE_COL () {
		echo -ne "\[\033[1;$1m\]"
}

#color code if root
function ROOT_COL () {
	if id | cut -d' ' -f1 | grep -i 'root' &> /dev/null
	then
		if [ $3 ]
		then
			EXT_COL $2
		else
			EXT_COL $2
		fi
	else
		EXT_COL $1
	fi
}

# reset colors
NC='\[\e[m\]'

USERCOL=`ROOT_COL 27 1 b`
ATCOL=$NC

# Indicate ssh session
if [ "$SSH_CONNECTION" == "" ]
then
	HOSTCOL=`EXT_COL 34`
	else
	HOSTCOL=`EXT_COL 208`
fi

PATHCOL=`EXT_COL 45`
BRANCHCOL=`EXT_COL 220`
RETURNCOL=`EXT_COL 9`
#TIMECOL=`EXT_COL 242`
PROMPTCOL=`EXT_COL 15`

# simple colors
S_USERCOL=`SIMPLE_COL 34`
S_PATHCOL=`SIMPLE_COL 36`
S_BRANCHCOL=`SIMPLE_COL 33`
S_RETURNCOL=`SIMPLE_COL 31`
#S_TIMECOL=`SIMPLE_COL 242`
S_PROMPTCOL=$NC
S_HOSTCOL=`SIMPLE_COL 32`

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
        status=`git status 2>&1 | tee`
        dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
		  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
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

# print returned error codes
function nonzero_return() {
   RETVAL=$?
   [ $RETVAL -ne 0 ] && echo " ⏎$RETVAL "
}

# don't use 256 colors if file exists
if [ -f ~/.simple_bash ]
then
	export PS1="$S_USERCOL\u$NC@$S_HOSTCOL\h$NC:$S_PATHCOL\W$S_RETURNCOL\`nonzero_return\`$S_BRANCHCOL\`parse_git_branch\`$S_PROMPTCOL\\$ $NC"
else
	export PS1="$USERCOL\u$NC$ATCOL@$HOSTCOL\h$NC:$PATHCOL\W$RETURNCOL\`nonzero_return\`$BRANCHCOL\`parse_git_branch\`$PROMPTCOL\\$ $NC"
fi

# switch to simple colors temporarily
function ps1s () {
	export PS1="$S_USERCOL\u$NC@$S_HOSTCOL\h$NC:$S_PATHCOL\W$S_RETURNCOL\`nonzero_return\`$S_BRANCHCOL\`parse_git_branch\`$S_PROMPTCOL\\$ $NC";
}

# keyswap if possible
keyswap &> /dev/null

# print archey if installed
if ! which archey 2>&1 | grep -i "no archey" &> /dev/null && which archey &> /dev/null
then
	archey
fi

# move up n directories
function up () {
	if [ "$#" -eq "0" ]
	then
		cd ../
	elif [ "$#" -gt "1" ]
	then
		echo "Usage: up [int]"
		return 2
	else
		case $1 in
			''|*[!0-9]*) echo "Usage: up [int]"; return 2 ;;
		esac
		numdirs=""
		for i in `seq 1 $1`
		do
			numdirs="$numdirs../"
		done
		cd $numdirs
	fi
}

#old PS1s, preserved for science

#two line with time
#PS1="\n$TIMECOL\@ $USERCOL \u $ATCOL@ $HOSTCOL\h $PATHCOL \w $RETURNCOL\`nonzero_return\`$BRANCHCOL \`parse_git_branch\`\`parse_git_dirty\` $NC\n\\$ "

# One line w/ time
#PS1="\[$TIMECOL\]\@\[$USERCOL\]\u\[$ATCOL\]@\[$HOSTCOL\]\h\[$PATHCOL\]\W\[$RETURNCOL\]\`nonzero_return\`\[$BRANCHCOL\]\`parse_git_branch\`\`parse_git_dirty\`\[$PROMPTCOL\]\\$ \[$NC\]"

# One line w/o time
#PS1="\[$USERCOL\]\u\[$NC\]\[$ATCOL\]@\[$HOSTCOL\]\h\[$NC\]:\[$PATHCOL\]\W\[$RETURNCOL\]\`nonzero_return\`\[$BRANCHCOL\]\`parse_git_branch\`\`parse_git_dirty\`\[$PROMPTCOL\]\\$ \[$NC\]"

#PS1="$USERCOL\u$ATCOL@$HOSTCOL\h$NC:$PATHCOL\W$RETURNCOL\`nonzero_return\`$BRANCHCOL\`parse_git_branch\`\`parse_git_dirty\`$ROOT_COL\\$ $NC"

#export PS1='\[\e[32;1m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\W $NC\$ '
