TERM=xterm-256color

[ -z "$PS1" ] && return # If not running interactively, don't do anything

HISTCONTROL=ignoreboth

shopt -s histappend   # append to history file
shopt -s checkwinsize # ensure window size is correct

set -o vi

export CLICOLOR=true

function EXT_COL () { echo -ne "\[\033[38;5;$1m\]"; }

NC='\e[m'   # reset colors

USERCOL=`EXT_COL 25`
ATCOL=`EXT_COL 26`
HOSTCOL=`EXT_COL 29`
PATHCOL=`EXT_COL 115`
BRANCHCOL=`EXT_COL 216`
RETURNCOL=`EXT_COL 9`
TIMECOL=`EXT_COL 242`

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function parse_git_dirty {
        status=`git status 2> /dev/null`
        dirty=`echo -n "${status}" 2> /dev/null | grep -q "modified:" 2> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep -q "Untracked files" 2> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep -q "Your branch is ahead of" 2> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep -q "new file:" 2> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep -q "renamed:" 2> /dev/null; echo "$?"`
        bits=''
        if [ "${dirty}" == "0" ]; then
                bits="${bits}⚡"
        fi
        if [ "${untracked}" == "0" ]; then
                bits="${bits}?"
        fi
        if [ "${newfile}" == "0" ]; then
                bits="${bits}+"
        fi
        if [ "${ahead}" == "0" ]; then
                bits="${bits}*"
        fi
        if [ "${renamed}" == "0" ]; then
                bits="${bits}>"
        fi
        echo "${bits}"
}

nonzero_return() {
   RETVAL=$?
   [ $RETVAL -eq 1 ] && echo " ⏎ $RETVAL "
}

PS1="\n$TIMECOL\@ $USERCOL \u $ATCOL@ $HOSTCOL\h $PATHCOL \w $RETURNCOL\`nonzero_return\`$BRANCHCOL \`parse_git_branch\`\`parse_git_dirty\` $NC\n\\$ "

if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

if [ -f ~/.bash_local ]; then
   . ~/.bash_local
fi

DEBEMAIL=rfrank.nj@gmail.com
DEBFULLNAME="Russell Frank"
export DEBEMAIL DEBFULLNAME

PATH=~/.bin/:~/node_modules/.bin/:/opt/local/bin/:$PATH

export EDITOR=vim

if [ -f ~/.nvm/nvm.sh ]; then
   . ~/.nvm/nvm.sh
fi

# {{{
# Node Completion - Auto-generated, do not touch.
shopt -s progcomp
for f in $(command ls ~/.node-completion); do
  f="$HOME/.node-completion/$f"
  test -f "$f" && . "$f"
done
# }}}
