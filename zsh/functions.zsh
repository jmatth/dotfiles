# functions.zsh: Custom functions, and function invocations.

if (( C == 256 )); then
    autoload spectrum && spectrum # Set up 256 color support.
else
    autoload colors && colors # Set up simple color support
fi

# Autoload some useful utilities.
autoload -Uz zmv
autoload -Uz zargs
autoload -Uz vcs_info

case $TERM in
    *xterm*|*rxvt*|*screen*)
        # Special function precmd, executed before displaying each prompt.
        function precmd() {
            # Set the terminal title to the current working directory.
            print -Pn "\e]0;%n@%m:%~\a"

            # Get the current git branch into the prompt.
            vcs_info
        }

        # Special function preexec, executed before running each command.
        function preexec () {
            # Set the terminal title to the curently running command.
            print -Pn "\e]2;[${2:q}]\a"
        }
esac

# move up n directories
function up () {
	if (( $# == 0 ))
	then
		cd ../
	elif (( $# > 1 ))
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

# Swap esc and capslock
function esc_keyswap () {
	if (($+1))
	then
		xmodmap -e 'keycode 9 = Caps_Lock' \
		-e 'keycode 66 = Escape' \
		-e 'remove Lock = Caps_Lock' \
		-e 'keycode 66 = Caps_Lock' \
		-e 'keycode 9 = Escape'
	else
		xmodmap -e 'keycode 66 = Caps_Lock' \
		-e 'keycode 9 = Escape' \
		-e 'remove Lock = Caps_Lock' \
		-e 'keycode 9 = Caps_Lock' \
		-e 'keycode 66 = Escape'
	fi
}
