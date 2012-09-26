# environment.zsh: Sets up a working shell environment.

typeset -U fpath
fpath=($Z/functions $fpath)

# Find out how many colors the terminal is capable of putting out.
# Color-related settings _must_ use this if they don't want to blow up on less
# endowed terminals.
C=$(tput colors)

# Important applications.
export EDITOR=vim
export BROWSER=google-chrome

# I guess it doesn't do this automatically
# if you set the editor in a separate file
bindkey -v

# History Settings
export SAVEHIST=2000
export HISTSIZE=2000
export HISTFILE=~/.zsh_history

# Zsh Reporting
export REPORTTIME=5
