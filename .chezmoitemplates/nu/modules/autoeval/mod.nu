# Abuse autoload files to work around nu's weird parse time design choices.

export const user_autoload = $nu.user-autoload-dirs.0

module core {
	export alias ls = ls
	export alias cd = cd
}
use core

# Change directory to where autoeval files are stored.
export def --env cd []: nothing -> nothing {
	core cd $user_autoload
}

# List current autoeval files on disk.
export def ls []: nothing -> table {
	core cd $user_autoload
	core ls -sf auto-*.nu
}

# Check that a file exists in the user autoload directory, and create it
# with the contents of the provided closure if not.
export def ensure [name: string, create: closure]: nothing -> nothing {
	mkdir $user_autoload
	let target_path = $user_autoload | path join $'auto-($name).nu'
	if not ($target_path | path exists) {
		do $create | save -f $target_path
	}
}

# Remove all files created by `autoload ensure`.
export def purge []: nothing -> string {
	glob ($user_autoload | path join 'auto-*.nu')
	| each {|p| rm -f $p; return $p }
}
