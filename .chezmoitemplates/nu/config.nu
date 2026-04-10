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
{{ if eq .theme "solarized" -}}
$env.nu_color_theme = {
    dark: 'solarized-dark',
    light: 'solarized-light',
}
{{ else if eq .theme "ayu" -}}
$env.nu_color_theme = {
    dark: 'ayu-mirage',
    light: 'ayu-light',
}
{{ else if eq .theme "rose-pine" -}}
$env.nu_color_theme = {
    dark: 'rose-pine-moon',
    light: 'rose-pine-dawn',
}
{{ end -}}
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
$env.MANPAGER = "nvim +Man!"

# The prompt indicators are environmental variables that represent the state of
# the prompt.
let palette = (theme fetch auto).palette.standard
let promptchar = if $isroot { $'(ansi {fg: red, attr: rb})#(ansi rst)' } else { '%' }
$env.PROMPT_INDICATOR = $'($promptchar)(ansi blue)>(ansi reset) '
$env.PROMPT_INDICATOR_VI_INSERT = $'($promptchar)(ansi blue)>(ansi reset) '
$env.PROMPT_INDICATOR_VI_NORMAL = $'($promptchar)(ansi red)[(ansi reset) '
$env.PROMPT_MULTILINE_INDICATOR = '::: '

$env.config.menus ++= [
    {
        name: history_menu
        only_buffer_difference: true # Search is done on the text written after activating the menu
        marker: $'(ansi {fg: blue attr: r})?(ansi rst)(ansi green)> ' # Indicator that appears with the menu is active
        type: {
            layout: list             # Type of menu
            page_size: 10            # Number of entries that will presented when activating the menu
        }
        style: {
            text: $palette.secondary             # Text style
            selected_text: { fg: green attr: r } # Text style for selected option
            description_text: yellow             # Text style for description
        }
    },
    {
        name: completion_menu
        only_buffer_difference: false                                   # Search is done on the text written after activating the menu
        marker: $'(ansi {fg: green attr: r})|(ansi rst)(ansi blue)> ' # Indicator that appears with the menu is active
        type: {
            layout: columnar          # Type of menu
            columns: 4                # Number of columns where the options are displayed
            col_width: 20             # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2            # Padding between columns
        }
        style: {
            text: green                          # Text style
            selected_text: { fg: green attr: r } # Text style for selected option
            description_text: yellow             # Text style for description
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
    gpg-connect-agent updatestartuptty /bye o+e>| ignore
    $env.SSH_AUTH_SOCK = $'(gpgconf --list-dirs agent-ssh-socket)'
    $env.GPG_TTY = ^tty
}

#
## Generated autoload files.
#
use autoeval

module prompt {
    def get_cmd_duration []: nothing -> string {
        # Nushell thinks "bug" and "easter egg" are synonyms:
        # https://github.com/nushell/nushell/discussions/6402#discussioncomment-3466687
        match $env.CMD_DURATION_MS {
            '0823' => 0
            $d     => $d
        }
    }

    export def --env 'truncate on' [] {
        $env.NU_PROMPT_TRUNCATE = true
    }

    export def --env 'truncate off' [] {
        $env.NU_PROMPT_TRUNCATE = false
    }

    export def get_starship_profiles [] {
        if (which starship | is-empty) { return {} }
        let starship_profiles = starship print-config | from toml | get profiles
        let base_profiles = $starship_profiles |
            columns |
            parse -r '^nu_([^_]+)$' |
            get capture0
        return (
            $base_profiles | each {|p| {
                name: $p
                has_right:     ($'nu_($p)_right' in $starship_profiles)
                has_transient: ($'nu_($p)_trans' in $starship_profiles)
                has_truncated: ($'nu_($p)_trunc' in $starship_profiles)
            }} |
            reduce -f {} {|it acc| $acc | upsert $it.name ($it | reject name) }
        )
    }

    def complete_prompt_name [context: string] {
        let starship_profiles = get_starship_profiles
        return {
            completions: [
                { value: builtin description: 'Default prompt built in to nushell' style: magenta }
                ...($starship_profiles | columns)
            ]
            options: {
                sort: false
            }
        }
    }

    export def --env use [prompt: string@complete_prompt_name]: nothing -> nothing {
        if $prompt == 'builtin' {
            $env.NU_PROMPT = null
            $env.PROMPT_COMMAND = null
            $env.PROMPT_COMMAND_RIGHT = null
            $env.TRANSIENT_PROMPT_COMMAND = null
            return
        }

        let prompt_info = get_starship_profiles | get $prompt
        $env.NU_PROMPT = $prompt
        $env.PROMPT_COMMAND = {|| do_prompt }
        $env.PROMPT_COMMAND_RIGHT = if $prompt_info.has_right { {|| do_prompt_right } } else { {|| ''} }
        $env.TRANSIENT_PROMPT_COMMAND = (do_prompt_trans --with-truncate=$prompt_info.has_truncated --with-transient=$prompt_info.has_transient)
    }

    def do_prompt []: nothing -> string {
        (ansi rst) + (
            ^starship prompt
                --profile ('nu_' + $env.NU_PROMPT)
                --cmd-duration (get_cmd_duration)
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
                --jobs (job list | length)
        )
    }

    def do_prompt_right []: nothing -> string {
        (
            ^starship prompt
                --profile ('nu_' + $env.NU_PROMPT + '_right')
                --cmd-duration (get_cmd_duration)
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
                --jobs (job list | length)
        )
    }

    def do_prompt_trans [
        --with-truncate
        --with-transient
    ] {
        if not ($with_transient or $with_truncate) {
            return null
        }
        return {||
            if ($with_truncate and $env.NU_PROMPT_TRUNCATE) {
                (
                    ^starship prompt
                    --profile ('nu_' + $env.NU_PROMPT + '_trunc')
                    --cmd-duration (get_cmd_duration)
                    $"--status=($env.LAST_EXIT_CODE)"
                    --terminal-width (term size).columns
                    --jobs (job list | length)
                )
            } else if $with_transient {
                (
                    ^starship prompt
                    --profile ('nu_' + $env.NU_PROMPT + '_trans')
                    --cmd-duration (get_cmd_duration)
                    $"--status=($env.LAST_EXIT_CODE)"
                    --terminal-width (term size).columns
                    --jobs (job list | length)
                )
            } else {
                ''
            }
        }
    }

    export-env {
        $env.STARSHIP_SHELL = "nu"
        $env.NU_PROMPT_TRUNCATE = false
        $env.NU_PROMPT = 'full'
        load-env {
            STARSHIP_SESSION_KEY: (random chars -l 16)
            PROMPT_MULTILINE_INDICATOR: (
                ^starship prompt --continuation
            )

            # Does not play well with default character module.
            # TODO: Also Use starship vi mode indicators?
            PROMPT_INDICATOR: ""

            PROMPT_COMMAND: {|| do_prompt }
            PROMPT_COMMAND_RIGHT: {|| do_prompt_right }
            TRANSIENT_PROMPT_COMMAND: {|| do_prompt_trans }

            config: ($env.config? | default {} | merge {
                render_right_prompt_on_last_line: true
            })
        }
    }
}
use prompt
prompt use full

if (which zoxide | is-not-empty) {
    autoeval ensure 'zoxide' {|| ^zoxide init nushell }
}

#
## Additional mise integration
#

# Generate nu module to handle mise integration. Probably won't work on initial
# install so this is mainly here to make periodically regenerating the module
# easier.
def 'mise nugen' []: nothing -> nothing {
    mkdir ($mise_mod_path | path dirname)
    mise activate nu | save -f $mise_mod_path
}

# Generate and load mise completions
if (which usage | is-not-empty) {
    autoeval ensure 'mise-completion' {||
        let tmpspec = mktemp
        mise usage | save -f $tmpspec
        let usage_contents = usage g completion nu mise -f $tmpspec
        rm $tmpspec
        return $usage_contents
    }
}


#
## Aliases and custom commands
#

# Write to the system clipboard.
def pbcopy []: any -> nothing {
    if $nu.os-info.name == 'windows' {
        ^clip
    } else if $nu.os-info.name == 'macos' {
        ^pbcopy
    } else if $nu.os-info.name == 'linux' {
        if (which wl-copy | is-not-empty) {
            ^wl-copy
        } else {
            error make "Missing system dependency wl-copy, install wl-clipboard"
        }
    } else {
        error make $"Don't know how to copy to clipboard on ($nu.os-info.name)"
    }
}

# Read from the system clipboard.
def pbpaste []: nothing -> string {
    if $nu.os-info.name == 'windows' {
        ^powershell -Command 'Get-Clipboard'
    } else if $nu.os-info.name == 'macos' {
        ^pbpaste
    } else if $nu.os-info.name == 'linux' {
        if (which wl-copy | is-not-empty) {
            ^wl-paste
        } else {
            error make "Missing system dependency wl-paste, install wl-clipboard"
        }
    } else {
        error make $"Don't know how to paste from clipboard on ($nu.os-info.name)"
    }
}

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

alias jobs = job list
{{ if ne .chezmoi.os "windows" -}}
alias fg = job unfreeze
{{- end }}

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
                insert type { $in.info.0? } |
                insert encoding { $in.info.1? } |
                reject info
        } else {
            update info { str trim | if $split_info { split row ', ' } else {} }
        } |
        metadata set --path-columns [name] |
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

module archive {
    def tabulate_tar []: string -> table {
        detect columns -n | rename mode owner size date time name |
        insert user  { get owner | split row '/' | first } |
        insert group { get owner | split row '/' | last } |
        reject owner |
        update size { into filesize } |
        move mode --after date |
        update date {|r| $'($r.date)T($r.time)+00:00' | into datetime } | reject time |
        move --first name | metadata set --path-columns [name]
    }

    # Of the provided options, return the first that is found in PATH, or the
    # last option if no matches are found.
    def choose_program [...options: string]: nothing -> string {
        $options | where (which ($it | split row ' ' | first) | is-not-empty) | first | default ($options | last)
    }

    def get_handler [input: path] {
        let handlers = [[matches list extract create];
            [[.tar.gz .tgz]
                {|i| tar tvzf $i | tabulate_tar }
                {|i| tar -xvf $i --use-compress-program=$'(choose_program unpigz gunzip)' }
                {|i: string, ...rest: glob|
                    tar -cvf $i --use-compress-program=$'(choose_program pigz gzip)' ...$rest
                }
            ]
            [[.tar.bz2 .tbz .tbz2]
                {|i| tar tvjf $i | tabulate_tar }
                {|i| tar -xvf $i --use-compress-program=$'(choose_program lbunzip2 pbunzip2 bunzip2)' }
                {|i, ...rest|
                    tar -cvf $i --use-compress-program=$'(choose_program lbzip2 pbzip2 bzip2)' ...$rest
                }
            ]
            [[.tar.xz .txz]
                {|i|
                    let tar_has_xz = (tar --xz --help | complete).exit_code == 0
                    if $tar_has_xz {
                        tar --xz -tvf $i | tabulate_tar
                    } else {
                        xzcat $i | tar tvf - | tabulate_tar
                    }
                }
                {|i| tar -xvf $i --use-compress-program=$'(choose_program "pixz -d" xz)' }
                {|i, ...rest|
                    tar -cvf $i --use-compress-program=$'(choose_program pixz xz)' ...$rest
                }
            ]
            [[.tar.zma .tlz]
                {|i|
                    let tar_has_lzma = (tar --lzma --help | complete).exit_code == 0
                    if $tar_has_lzma {
                        tar --lzma -tvf $i | tabulate_tar
                    } else {
                        lzcat $i | tar tvf - | tabulate_tar
                    }
                }
                {|i|
                    let tar_has_lzma = (tar --lzma --help | complete).exit_code == 0
                    if $tar_has_lzma {
                        tar --lzma -xvf $i
                    } else {
                        lzcat $i | tar -xvf -
                    }
                }
                {|i, ...rest| tar -cvf $i --lzma ...$rest }
            ]
            [[.tar.zst .tzst]
                {|i| tar -I zstd -tvf $i | tabulate_tar }
                {|i| tar -xvf $i --use-compress-program='zstd' }
                {|i, ...rest| tar -cvf $i --use-compress-program='zstd' ...$rest }
            ]
            [[.tar]
                {|i| tar tvf $i | tabulate_tar }
                {|i| tar -xvf $i }
                {|i, ...rest| tar -cvf $i ...$rest }
            ]
            [[.zip .jar]
                {|i|
                    unzip -lv $i |
                    detect columns -s 1 --guess |
                    skip 1 | drop 2 |
                    rename -b { str downcase } |
                    move --first name |
                    update size { into filesize } | update length { into filesize } |
                    update date {|r| $'($r.date)T($r.time)+00:00' | into datetime } | reject time |
                    metadata set --path-columns [name]
                }
                {|i|
                    let extract_dir = ($i | path parse | get stem)
                    unzip $i -d $extract_dir
                }
                {|i, ...rest| ^zip -r $i ...$rest}
            ]
            [[.rar]
                {|i|
                    if (which unrar | is-not-empty) {
                        unrar v $i | detect columns --skip 6 | skip 1 | drop 2 |
                        rename -b { str downcase } |
                        update size { into filesize } |
                        update packed { into filesize } |
                        update date {|r| $'($r.date)T($r.time)+00:00' | into datetime } | reject time |
                        move name --first | metadata set --path-columns [name]
                    } else if (which rar | is-not-empty) {
                        rar v $i
                    } else {
                        lsar -l $i
                    }
                }
                {|i|
                    if (which unrar | is-not-empty) {
                        unrar x -ad $i
                    } else if (which rar | is-not-empty) {
                        rar x -ad $i
                    } else {
                        unar -d $i
                    }
                }
                {|i, ...rest| rar a $i ...$rest}
            ]
            [[.7z]
                {|i|
                    7za l $i | detect columns -s 18 --guess | skip 1 | drop 2 |
                    rename -b { str downcase } |
                    update date {|r| $'($r.date)T($r.time)+00:00' | into datetime } | reject time |
                    update size { into filesize } | update compressed { if ($in | is-not-empty) { $in | into filesize } else { null } } |
                    move name --first | metadata set --path-columns [name]
                }
                {|i| 7za x $i }
                {|i, ...rest| 7za a $i ...$rest }
            ]
        ]
        $handlers | where ($it.matches | any {|s| $input | str ends-with $s }) | first
    }

    # List the contents of common archive formats.
    export def list [input: path] {
        let h = get_handler $input
        do $h.list $input
    }

    # Extract common archive formats.
    export def extract [input: path] {
        let h = get_handler $input
        do $h.extract $input
    }

    # Create an archive in a common format. Format is determined by the
    # extension of the first argument.
    export def create [
        archive: path
        # Path to file archive to create. If a file already exists at this path it may be overwritten.
        ...inputs: glob
        # Files to include in the archive.
    ] {
        let h = get_handler $archive
        do $h.create $archive ...$inputs
    }
}
use archive

# Open a new tmux window with permutations of a command.
def tplex [
    --session (-s): string
    # Session to use. Defaults to the current session if already inside tmux and '0' otherwise. Session must already exist.
    --window (-w): string
    # Window to use/create. Defaults to current highest window + 1.
    --sync = true
    # Synchronize pane input after all commands are started.
    base_cmd: string
    # Command to run in each pane, such as `ssh`.
    ...rest: string
    # Arguments to pass to `base_cmd` per-pane, such as `host1 host2 host3`.
]: nothing -> nothing {
    if (which tmux | is-empty) {
        print 'tmux not found'
        return
    }

    if ($rest | is-empty) {
        print 'must provide at least one argument permutation'
        return
    }

    let effective_session = if ($session | is-not-empty) {
        $session
    } else if ($env.TMUX? | is-not-empty) {
        tmux display-message -p '#S'
    } else {
        '0'
    }

    let effective_window = if ($window | is-not-empty) {
        $window
    } else {
        tmux list-windows -t $effective_session |
            parse '{name}: {title} ({paneCount} panes) [{width}x{height}]{_}' |
            get name |
            into int |
            last |
            each {|i| $i + 1 }
    }

    mut pane = 0
    tmux new-window -t $"($effective_session):($effective_window)" -n 'tplex' -d
    for cmd in $rest {
        if $pane >= 1 {
            tmux split-window -d -t $'($effective_window).($pane - 1)' -h
        }
        tmux select-pane -t $'($effective_window).($pane)'
        tmux send-keys -t $'($effective_window).($pane)' $'($base_cmd) ($cmd)' C-m
        tmux select-layout -t $'($effective_session):($effective_window)' tiled
        $pane += 1
    }

    if $sync {
        tmux set -w -t $'($effective_session):($effective_window)' synchronize-panes
    }
}
