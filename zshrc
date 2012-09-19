# Where extra files are stored
Z=~/.zsh

# Add custom scripts to the fpath
typeset -U fpath
fpath=($Z/functions $fpath)

# All the colors
export TERM=xterm-256color

# Set programs to use
# Note: setting editor to vim also sets
# zsh mode to vi instead of emacs
export EDITOR=vim

# History settings
export SAVEHIST=2000
export HISTSIZE=2000
export HISTFILE=~/.zsh_history

### zsh Options ###
# Directories
setopt AUTO_CD                      # Automatically cd in to directories if it's not a command name.
#setopt AUTO_PUSHD                   # Automatically push visited directories to the stack.
#setopt PUSHD_IGNORE_DUPS            # ...and don't duplicate them.

# History
setopt APPEND_HISTORY               # Don't overwrite history.
setopt HIST_VERIFY                  # Verify commands that use a history expansion.
setopt EXTENDED_HISTORY             # Remember all sorts of stuff about the history.
setopt INC_APPEND_HISTORY           # Incrementally append commands to the history.
setopt HIST_IGNORE_SPACE            # Ignore commands with leading spaces.
setopt HIST_IGNORE_ALL_DUPS         # Ignore all duplicate entries in the history.
setopt HIST_REDUCE_BLANKS           # Tidy up commands before comitting them to history.

# Completion
setopt AUTO_LIST                    # Always automatically show a list of ambiguous completions.
setopt COMPLETE_IN_WORD             # Complete items from the beginning to the cursor.

setopt NO_BEEP                      # STFU

setopt PROMPT_SUBST                 # Expand parameters within prompts.

setopt LOCAL_OPTIONS                # Options set/unset inside functions, stay within the function.
setopt INTERACTIVE_COMMENTS         # Allow me to comment lines in an interactive shell.

setopt RM_STAR_WAIT                 # Wait, and ask if the user is serious when doing rm *

setopt EXTENDED_GLOB                # Give meaning to lots of crazy characters.

#setopt MULTIBYTE
#unsetopt FLOW_CONTROL               # Don't allow suspend/resume characters in the editor.

### end zsh options ###

# Report runtime for programs that take a while
export REPORTTIME=5

# Aliases
alias zmod="vim ~/.zshrc"
alias zsave="source ~/.zshrc"
alias vmod="vim ~/.vimrc"
alias sudo="sudo -E"

# Load functions
autoload -Uz zmv                    # massive rename
autoload -Uz zargs                  # similar to xargs
autoload -Uz vcs_info               # version control information

# Enable completion
autoload -Uz compinit && compinit

zstyle ':completion:*' list-colors "${LS_COLORS}" # Complete with same colors as ls.
zstyle ':completion:*' max-errors 2 # Be lenient to 2 errors.
zstyle ':completion:*' completer _expand _complete _correct _approximate # Completion modifiers.
zstyle ':completion:*' use-cache true # Use a completion cache.
zstyle ':completion:*' ignore-parents pwd # Ignore the current directory in completions.

case $TERM in
	*xterm*|*rxvt*|*screen*|)
		# Special function precmd, run before displaying each prompt
		function precmd () {
			# Set the terminal title to the current working directory
            print -Pn "\e]0;%n@%m:%~\a"

			# Get the current git branch
			vcs_info
		}

		# Special function preexec, executed before running each command
		function preexec () {
			# Set the terminal title to the currently running command
            print -Pn "\e]2;[${2:q}]\a"
		}
esac

### zsh prompt config ###

autoload spectrum && spectrum

function ROOT_COL () {
	if id | cut -d' ' -f1 | grep -i 'root' &> /dev/null
	then
		echo "%{$FX[reset]$FX[bold]$FX[$1]%}"
	else
		echo "%{$FX[reset]$FX[bold]$FX[$2]%}"
}

function SSH_COL () {
	if (($+SSH_CONNECTION))
	then
		echo "%{$FX[reset]$FX[bold]$FX[$1]%}"
	else
		echo "%{$FX[reset]$FX[bold]$FX[$2]%}"
}

local NC="%{$FX[reset]%}"

local usercol=`ROOT_COL 027 001`
local hostcol=`SSH_COL 208 034`
local pathcol="%{$FX[reset]$FX[bold]$FX[045]%}"
local branchcol="%{$FX[reset]$FX[bold]$FX[220]%}"
local returncol="%{$FX[reset]$FX[bold]$FX[009]%}"

# Use zshcontrib's vcs_info to get information about any current version control systems.
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$FX[reset]$FG[082]%}"
zstyle ':vcs_info:*' unstagedstr "%{$FX[reset]$FG[160]%}"
zstyle ':vcs_info:*' formats ":%{$FX[reset]$FG[222]%}%c%u%b"

local vcsi="\${vcs_info_msg_0_}"

PROMPT="${p}${usercol}%n${p}@${hostcol}%m${p}:${pathcol}%~${p}${vcsi}${p}${NC}% "
