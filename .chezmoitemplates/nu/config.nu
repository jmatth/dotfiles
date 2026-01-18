# config.nu
#
# Installed by:
# version = "0.106.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R
use std/util "path add"
use std/dirs

use git/aliases *
use git/ngit
use git/ngit aliases *

# Disable the welcome banner.
# Run `banner` to show it manually for checking stuff like startup time.
$env.config.show_banner = false

# ------------------------
# History-related settings
# ------------------------
# $env.config.history.*

# file_format (string):  Either "sqlite" or "plaintext". While text-backed history
# is currently the default for historical reasons, "sqlite" is stable and
# provides more advanced history features.
$env.config.history.file_format = "sqlite"

# max_size (int): The maximum number of entries allowed in the history.
# After exceeding this value, the oldest history items will be removed
# as new commands are added.
$env.config.history.max_size = 5_000_000

# sync_on_enter (bool): Whether the plaintext history file is updated
# each time a command is entered. If set to `false`, the plaintext history
# is only updated/written when the shell exits. This setting has no effect
# for SQLite-backed history.
# $env.config.history.sync_on_enter = true

# isolation (bool):
# `true`: New history from other currently-open Nushell sessions is not
# seen when scrolling through the history using PrevHistory (typically
# the Up key) or NextHistory (Down key)
# `false`: All commands entered in other Nushell sessions will be mixed with
# those from the current shell.
# Note: Older history items (from before the current shell was started) are
# always shown
# This setting only applies to SQLite-backed history
$env.config.history.isolation = true

if not ($env.SHELL? | default '' | str ends-with /nu) {
    $env.SHELL = $nu.current-exe
}

let isroot = do {
    if (which id | is-empty) {
        return false
    }
    return ((id -u | into int) == 0)
}

use theme
theme set auto

if $env.TERM? == 'linux' {
    $env.config.table.mode = 'single'
}

$env.config.render_right_prompt_on_last_line = true

$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.cursor_shape.vi_normal = "block"
$env.config.cursor_shape.vi_insert = "block"

# The prompt indicators are environmental variables that represent the state of
# the prompt.
let solarized = theme generate false
let promptchar = if $isroot { $'(ansi {fg: $solarized.palette.red, attr: rb})#(ansi rst)' } else { '%' }
$env.TRANSIENT_PROMPT_COMMAND = {||
    do $env.PROMPT_COMMAND | str replace '─╮' ''
}
$env.PROMPT_INDICATOR = $'($promptchar)(ansi $solarized.palette.blue)>(ansi reset) '
$env.PROMPT_INDICATOR_VI_INSERT = $'($promptchar)(ansi $solarized.palette.blue)>(ansi reset) '
$env.PROMPT_INDICATOR_VI_NORMAL = $'($promptchar)(ansi red)[(ansi reset) '
$env.PROMPT_MULTILINE_INDICATOR = '::: '

$env.config.menus ++= [
    {
        name: history_menu
        only_buffer_difference: true # Search is done on the text written after activating the menu
        marker: $'(ansi {fg: $solarized.palette.green attr: r})?(ansi rst)(ansi $solarized.palette.blue)> ' # Indicator that appears with the menu is active
        type: {
            layout: list             # Type of menu
            page_size: 10            # Number of entries that will presented when activating the menu
        }
        style: {
            text: $solarized.palette.sec                            # Text style
            selected_text: { fg: $solarized.palette.green attr: r } # Text style for selected option
            description_text: $solarized.palette.yellow             # Text style for description
        }
    },
    {
        name: completion_menu
        only_buffer_difference: false                                   # Search is done on the text written after activating the menu
        marker: $'(ansi {fg: $solarized.palette.green attr: r})|(ansi rst)(ansi $solarized.palette.blue)> ' # Indicator that appears with the menu is active
        type: {
            layout: columnar          # Type of menu
            columns: 4                # Number of columns where the options are displayed
            col_width: 20             # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2            # Padding between columns
        }
        style: {
            text: $solarized.palette.green                          # Text style
            selected_text: { fg: $solarized.palette.green attr: r } # Text style for selected option
            description_text: $solarized.palette.yellow             # Text style for description
        }
    },
]

$env.CARAPACE_MATCH = 'CASE_INSENSITIVE'
$env.CARAPACE_EXCLUDES = 'nvim,vim,vi'
let carapace_completer = {|spans|
  # if the current command is an alias, get its expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans | skip 1 | prepend ($spans.0)
  })

  carapace $spans.0 nushell ...$spans | from json
}
$env.config.completions.external = {
    enable: true
    max_results: 100
    completer: $carapace_completer
}
$env.config.completions.algorithm = "fuzzy"
$env.config.completions.case_sensitive = false
$env.config.completions.sort = "smart"
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.use_ls_colors = true

# Use GPG as SSH agent
if $nu.os-info.family == unix and 'SSH_TTY' not-in $env {
    gpg-connect-agent updatestartuptty /bye | ignore
    $env.SSH_AUTH_SOCK = $'(gpgconf --list-dirs agent-ssh-socket)'
    $env.GPG_TTY = ^tty
}

#
## Generated autoload files.
#
use autoeval

if (which starship | is-not-empty) {
    $env.STARSHIP_SHELL = "nu"
    autoeval ensure 'starship' {|| ^starship init nu }
}

if (which zoxide | is-not-empty) {
    autoeval ensure 'zoxide' {|| ^zoxide init nushell }
}

#
## Aliases and custom commands
#

# Open Yazi file manager and update $env.PWD when it exits
def --wrapped --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

alias grep = rg
alias vrg = rg --vimgrep

alias code = codium

alias la = ls -a
alias ll = ls -la
alias tree = eza -T

# Run ls and l
def lg []: [nothing -> string] {
    ls |
        sort-by type name -i |
        grid -ic |
        str trim
}

# Start Kanata
def kk [] {
    let kanata = (which kanata).0.path
    if ($kanata | is-empty) {
        print 'Could not find kanata, not installed or missing from PATH?'
        return
    }
    sudo $kanata -n -c $"($nu.home-dir)/.kanata.kdb"
}

# Create a directory and cd into it
def --env mkcd [dir: string]: nothing -> nothing {
    if ($dir | str length) < 1 {
        return
    }
    mkdir $dir
    cd $dir
}

# Move up n directories (default 1)
def --env up [levels: int = 1]: nothing -> nothing {
    if $levels < 1 {
        return
    }
    cd (generate {|i| if $i > 0 { {out: '../', next: ($i - 1)} } } $levels | str join)
}

# Wrapper around the file utility available on most Unix systems. Returns a
# table in most cases. Piping in a single string will return a record.
# Arguments are automatically treated as globs, similar to ls. If arguments
# are provided and values are piped in they will be combined in the underlying
# call to the file binary.
def file [
    --mime(-i)                 # Output mime type strings instead human readable strings
    --dereference(-L)          # Follow symlinks
    --no-buffer(-n)            # Flush stdout after checking each file
    --preserve-date(-p)        # Attempt to preserve the access time of files analyzed
    --raw(-r)                  # Dont translate unprintable characters to octal
    --special-files(-s)        # Read block and character device files too
    --uncompress(-z)           # Try to look inside compressed files
    --split-info(-m)           # Split the info string around `, `. Ignored if `--mime` is set.
    ...files: glob
]: [
    nothing -> table
    string -> record
    glob -> table
    list<string> -> table
    list<glob> -> table
] {
    let args = [
        ...(if $mime { ['--mime'] })
        ...(if $dereference { ['--dereference'] } else {[ '--no-dereference' ]})
        ...(if $no_buffer { ['--no-buffer'] })
        ...(if $preserve_date { ['--preserve-date'] })
        ...(if $raw { ['--raw'] })
        ...(if $special_files { ['--special-files'] })
        ...(if $uncompress { ['--uncompress'] })
        ...$files
    ]
    let input = $in
    let inargs = match ($input | describe | str replace --regex '<.*' '') {
        'list' => $input,
        'nothing' => [],
        _ => [$input],
    }
    ^file ...$args ...$inargs |
        parse '{name}: {info}' |
        if $mime {
            update info { str trim | split row '; ' } |
                insert type { $in.info.0 } |
                insert encoding { $in.info.1 } |
                reject info
        } else {
            update info { str trim | if $split_info { split row ', ' } else {} }
        } |
        metadata set -l |
        if ($files | is-empty) and ($input | describe) == string {
            first
        } else {}
}

# Visually test ANSI color support
def colortest []: nothing -> nothing {
    def printcolor [fgbg: int, color: int, txt: string = '::']: nothing -> nothing {
        print -ne $'(ansi csi)($fgbg);5;($color)m($txt)'
    }

    print '256 color mode'
    [38 48] | each {|fgbg|
        print 'System colors'
        0..15 | each {|color|
            if $color == 8 {
                print -ne $"(ansi rst)\n"
            }
            printcolor $fgbg $color
        }
        print -ne $"(ansi rst)\n\n"

        print 'Color cube, 6x6x6'
        0..5 | each {|green| 
            0..5 | each {|red| 
                0..5 | each {|blue| 
                    let color = 16 + ($red * 36) + ($green * 6) + $blue
                    printcolor $fgbg $color
                }
                print -ne $"(ansi rst) "
            }
            print -ne $"\n"
        }

        print 'Greyscale ramp'
        232..255 | each {|color|
            printcolor $fgbg $color
        }
        print -ne $"(ansi rst)\n\n"
    }

    return null
}
