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

# -----------
# Set up PATH
# -----------
if (uname).kernel-name == 'Darwin' {
	path add '/opt/homebrew/sbin'
	path add '/opt/homebrew/bin'
}
path add ($nu.home-dir | path join .local bin)
path add ($nu.home-dir | path join .pixi bin)
path add ($nu.home-dir | path join .cargo bin)
path add ($nu.home-dir | path join go bin)

# -----------
# Set up mise
# -----------
const mise_mod_path = $nu.default-config-dir | path join scripts mise.nu
use $mise_mod_path
# Mise doesn't run the full env update code on activation. Manually update PATH
# so future config files can use tools installed through mise.
$env.PATH = mise hook-env -f -s nu
| from csv -n
| rename op name val
| where op == set and ($it.name | str uppercase) == PATH
| last
| get val
| split row (char esep)

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
$env.config.history.file_format = 'sqlite'

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
	dark: 'solarized-dark'
	light: 'solarized-light'
}
{{ else if eq .theme "ayu" -}}
$env.nu_color_theme = {
	dark: 'ayu-mirage'
	light: 'ayu-light'
}
{{ else if eq .theme "rose-pine" -}}
$env.nu_color_theme = {
	dark: 'rose-pine-moon'
	light: 'rose-pine-dawn'
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
		type: {layout: list, page_size: 10}
		style: {
			text: $palette.secondary # Text style
			selected_text: {fg: green, attr: r} # Text style for selected option
			description_text: yellow # Text style for description
		}
	}
	{
		name: completion_menu
		only_buffer_difference: false # Search is done on the text written after activating the menu
		marker: $'(ansi {fg: green attr: r})|(ansi rst)(ansi blue)> ' # Indicator that appears with the menu is active
		type: {
			layout: columnar # Type of menu
			columns: 4 # Number of columns where the options are displayed
			col_width: 20 # Optional value. If missing all the screen width is used to calculate column width
			col_padding: 2 # Padding between columns
		}
		style: {
			text: green # Text style
			selected_text: {fg: green, attr: r} # Text style for selected option
			description_text: yellow # Text style for description
		}
	}
]

let carapace_completer = {|place|
	$env.CARAPACE_MATCH = 'CASE_INSENSITIVE'
	$env.CARAPACE_EXCLUDES = 'nvim,vim,vi'
	$env.CARAPACE_LENIENT = 1
	carapace $place.command.0 nushell ...$place.command | from json
}
let fish_completer = {|place|
	fish --command $"complete '--do-complete=($place.command | str replace --all "'" "\\'" | str join ' ')'"
	| from tsv --flexible --noheaders --no-infer
	| rename value description
	| update value {|row|
		let value = $row.value
		let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
		if ($need_quote and ($value | path exists)) {
			let expanded_path = if ($value starts-with '~') {$value | path expand --no-symlink} else {$value}
			$'"($expanded_path | str replace --all "\"" "\\\"")"'
		} else {$value}
	}
}
$env.nu_completers = {
	nu: fish
	git: fish
}
let external_completer = {|place|
	match ($env.nu_completers? | default {} | get -o $place.command.0) {
		fish => $fish_completer
		_ => $carapace_completer
	} | do $in $place
}
$env.config.completions.external = {
	enable: true
	max_results: 100
	completer: $external_completer
}
$env.config.completions.algorithm = 'fuzzy'
$env.config.completions.case_sensitive = false
$env.config.completions.sort = 'smart'
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.use_ls_colors = true

# Use GPG as SSH agent
if $nu.os-info.family == unix and 'SSH_TTY' not-in $env {
    gpg-connect-agent updatestartuptty /bye o+e>| ignore
    $env.SSH_AUTH_SOCK = $'(gpgconf --list-dirs agent-ssh-socket)'
    $env.GPG_TTY = ^tty
}

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
		let base_profiles = $starship_profiles
		| columns
		| parse -r '^nu_([^_]+)$'
		| get capture0
		return (
			$base_profiles
			| each {|p| {
				name: $p
				has_right: ($'nu_($p)_right' in $starship_profiles)
				has_transient: ($'nu_($p)_trans' in $starship_profiles)
				has_truncated: ($'nu_($p)_trunc' in $starship_profiles)
			}}
			| reduce -f {} {|it acc| $acc | upsert $it.name ($it | reject name) }
		)
	}

	def complete_prompt_name [context: string] {
		let starship_profiles = get_starship_profiles
		return {
			completions: [
				{value: builtin, description: 'Default prompt built in to nushell', style: magenta}
				...($starship_profiles | columns)
			]
			options: {sort: false}
		}
	}

	export def --env set [prompt: string@complete_prompt_name]: nothing -> nothing {
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
		$env.PROMPT_COMMAND_RIGHT = if $prompt_info.has_right {
			{|| do_prompt_right }
		} else {
			{|| '' }
		}
		$env.TRANSIENT_PROMPT_COMMAND = (
			do_prompt_trans --with-truncate=$prompt_info.has_truncated --with-transient=$prompt_info.has_transient
		)
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

	def do_prompt_trans [--with-truncate, --with-transient] {
		if not ($with_transient or $with_truncate) {
			return null
		}
		return {||
			if $with_truncate and $env.NU_PROMPT_TRUNCATE {
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
			PROMPT_INDICATOR: "", 

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
prompt set full

#
## Generated autoload files.
#
use autoeval

if (which zoxide | is-not-empty) {
	autoeval ensure 'zoxide' {|| ^zoxide init nushell }
}

if (which atuin | is-not-empty) {
	# pty-proxy must load before the primary atuin module
	autoeval ensure 'atuin-00-pty-proxy' {|| ^atuin pty-proxy init nu }
	autoeval ensure 'atuin-10-main'      {|| ^atuin init nu --disable-ai --disable-up-arrow }
}

#
## Additional mise integration
#

# Generate nu module to handle mise integration. Probably won't work on initial
# install so this is mainly here to make periodically regenerating the module
# easier.
def 'mise nugen' []: nothing -> nothing {
	mkdir ($mise_mod_path | path dirname)
	^mise activate nu | save -f $mise_mod_path
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
			error make 'Missing system dependency wl-copy, install wl-clipboard'
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
alias nvp = nvim - +Man!

alias jobs = job list
{{ if ne .chezmoi.os "windows" -}}
alias fg = job unfreeze
{{- end }}

# Run ls and l
def lg []: nothing -> string {
	ls
	| sort-by type name -i
	| grid -ic
	| str trim
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
	--mime(-i)          # Output mime type strings instead human readable strings
	--dereference(-L)   # Follow symlinks
	--no-buffer(-n)     # Flush stdout after checking each file
	--preserve-date(-p) # Attempt to preserve the access time of files analyzed
	--raw(-r)           # Dont translate unprintable characters to octal
	--special-files(-s) # Read block and character device files too
	--uncompress(-z)    # Try to look inside compressed files
	--split-info(-m)    # Split the info string around `, `. Ignored if `--mime` is set.
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
		...(if $dereference { ['--dereference'] } else { ['--no-dereference'] })
		...(if $no_buffer { ['--no-buffer'] })
		...(if $preserve_date { ['--preserve-date'] })
		...(if $raw { ['--raw'] })
		...(if $special_files { ['--special-files'] })
		...(if $uncompress { ['--uncompress'] })
		...$files
	]
	let input = $in
	let inargs = match ($input | describe | str replace --regex '<.*' '') {
		'list' => $input
		'nothing' => []
		_ => [$input]
	}
	^file ...$args ...$inargs
	| parse '{name}: {info}'
	| if $mime {
		update info { str trim | split row '; ' }
		| insert type { $in.info.0? }
		| insert encoding { $in.info.1? }
		| reject info
	} else {
		update info { str trim | if $split_info { split row ', ' } else {} }
	}
	| metadata set --path-columns [name]
	| if ($files | is-empty) and ($input | describe) == string {
		first
	} else { }
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

# List, extract, and create archives of various common formats.
module archive {
	def maybe_parse [tabulate: closure, raw: bool]: string -> oneof<table, string> {
		if $raw { } else { do $tabulate }
	}

	def tabulate_tar []: string -> table {
		detect columns -n --guess
		| rename mode owner size date time name
		| insert user { get -o owner | default '' | split row '/' | first }
		| insert group { get -o owner | default '' | split row '/' | last }
		| reject -o owner
		| update size { into filesize }
		| move mode --after date
		| update date {|r| try { $'($r.date)T($r.time)+00:00' | into datetime } }
		| reject time
		| move --first name
		| metadata set --path-columns [name]
	}

	def tabulate_zip []: string -> table {
		detect columns --skip 1 --guess |
		skip 1 | drop 2 |
		rename -b { str lowercase } |
		move --first name |
		update size { into filesize } | update length { into filesize } |
		update date {|r| $'($r.date)T($r.time)+00:00' | into datetime } | reject time |
		metadata set --path-columns [name]
	}

	def tabulate_rar []: string -> table {
		detect columns --skip 6 | skip 1 | drop 2
		| rename -b { str lowercase }
		| update size { into filesize }
		| update packed { into filesize }
		| update date {|r| $'($r.date)T($r.time)+00:00' | into datetime } | reject time
		| move name --first | metadata set --path-columns [name]
	}

	def tabulate_7z []: string -> table {
		detect columns -s 18 --guess | skip 1 | drop 2
		| rename -b { str lowercase }
		| update date {|r| $'($r.date)T($r.time)+00:00' | into datetime } | reject time
		| update size { into filesize } | update compressed { if ($in | is-not-empty) { $in | into filesize } else { null } }
		| move name --first | metadata set --path-columns [name]
	}

	def tabulate_deb []: string -> table {
		detect columns -n
		| rename mode owner size date time name
		| update size { into filesize }
		| insert user { get owner | split row / | first }
		| insert group { get owner | split row / | last }
		| reject owner
		| update date {|r| $'($r.date)-($r.time)Z' | into datetime }
		| reject time
		| metadata set --path-columns [name]
		| select name size date mode user group
	}

	# Of the provided options, return the first that is found in PATH, or the
	# last option if no matches are found.
	def choose_program [...options: string]: nothing -> string {
		$options | where (which ($it | split row ' ' | first) | is-not-empty) | first | default ($options | last)
	}

	def extract_tar [input: path, programs: list<string>, to?: path]: nothing -> nothing {
		tar -xvf $input --use-compress-program=$'(choose_program ...$programs)' ...(if ($to | is-not-empty) { [-C $to] })
	}

	def handlers []: nothing -> table<matches: list<string>, list: closure, extract: closure, create: closure> {
		[[matches list extract create];
			[[.tar.gz .tgz]
				{|i, raw| tar tvzf $i | maybe_parse { tabulate_tar } $raw }
				{|i, to| extract_tar $i [unpigz gunzip] $to }
				{|i: string, ...rest: glob|
					tar -cvf $i --use-compress-program=$'(choose_program pigz gzip)' ...$rest
				}
			]
			[[.tar.bz2 .tbz .tbz2]
				{|i, raw| tar tvjf $i | maybe_parse { tabulate_tar } $raw }
				{|i, to| extract_tar $i [lbunzip2 pbunzip2 bunzip2] $to }
				{|i, ...rest|
					tar -cvf $i --use-compress-program=$'(choose_program lbzip2 pbzip2 bzip2)' ...$rest
				}
			]
			[[.tar.xz .txz]
				{|i, raw|
					let tar_has_xz = (tar --xz --help | complete).exit_code == 0
					if $tar_has_xz {
						tar --xz -tvf $i
					} else {
						xzcat $i | tar tvf -
					} | maybe_parse { tabulate_tar } $raw
				}
				{|i, to| extract_tar $i ['pixz -d' xz] $to }
				{|i, ...rest|
					tar -cvf $i --use-compress-program=$'(choose_program pixz xz)' ...$rest
				}
			]
			[[.tar.zma .tlz]
				{|i, raw|
					let tar_has_lzma = (tar --lzma --help | complete).exit_code == 0
					if $tar_has_lzma {
						tar --lzma -tvf $i
					} else {
						lzcat $i | tar tvf -
					} | maybe_parse { tabulate_tar } $raw
				}
				{|i, to|
					let tar_has_lzma = (tar --lzma --help | complete).exit_code == 0
					if $tar_has_lzma {
						tar --lzma -xvf $i ...(if ($to | is-not-empty) { [-C $to] })
					} else {
						lzcat $i | tar -xvf ...(if ($to | is-not-empty) { [-C $to] }) -
					}
				}
				{|i, ...rest| tar -cvf $i --lzma ...$rest }
			]
			[[.tar.zst .tzst]
				{|i, raw| tar -I zstd -tvf $i | maybe_parse { tabulate_tar } $raw }
				{|i, to| extract_tar $i [zstd] $to }
				{|i, ...rest| tar -cvf $i --use-compress-program='zstd' ...$rest }
			]
			[[.tar]
				{|i, raw| tar tvf $i | maybe_parse { tabulate_tar } $raw }
				{|i, to| tar -xvf $i ...(if ($to | is-not-empty) { [-C $to] }) }
				{|i, ...rest| tar -cvf $i ...$rest }
			]
			[[.zip .jar]
				{|i, raw| unzip -lv $i | maybe_parse { tabulate_zip } $raw }
				{|i, to|
					let extract_dir = if ($to | is-not-empty) {
						$to
					} else {
						$i | path parse | get stem
					}
					unzip $i -d $extract_dir
				}
				{|i, ...rest| ^zip -r $i ...$rest}
			]
			[[.rar]
				{|i, raw|
					if (which unrar | is-not-empty) {
						unrar v $i | maybe_parse { tabulate_rar } $raw
					} else if (which rar | is-not-empty) {
						rar v $i
					} else {
						lsar -l $i
					}
				}
				{|i, to|
					if (which unrar | is-not-empty) {
						unrar x -ad $i ...(if ($to | is-not-empty) { [$to] })
					} else if (which rar | is-not-empty) {
						rar x -ad $i ...(if ($to | is-not-empty) { [$to] })
					} else {
						unar -d $i ...(if ($to | is-not-empty) { [-o $to] })
					}
				}
				{|i, ...rest| rar a $i ...$rest}
			]
			[[.7z]
				{|i, raw| 7za l $i | maybe_parse { tabulate_7z } $raw }
				{|i, to| 7za x $i ...(if ($to | is-not-empty) { [$'-o($to)'] }) }
				{|i, ...rest| 7za a $i ...$rest }
			]
			[[.rpm]
				{|i, raw| rpm2archive --format pax $i | tar tvz | maybe_parse { tabulate_tar } $raw }
				{|i, to| rpm2archive --format pax $i | tar xvz ...(if ($to | is-not-empty) { [-C $to] }) }
				{|i, ...rest| error make 'rpm creation not supported' }
			]
			[[.deb]
				{|i, raw| dpkg-deb -c $i | maybe_parse { tabulate_deb } $raw }
				{|i, to| dpkg-deb -v -x $i (if ($to | is-not-empty) { $to } else { '.' }) }
				{|i, ...rest| error make 'deb creation not supported' }
			]
		]
	}

	def get_extension []: string -> string {
		path basename | split row . | skip 1 | str join .
	}

	def extensions [] {
		let exts = handlers | get matches | each { first } | str substring 1..
		{
			options: {
				case_sensitive: false
				completion_algorithm: prefix
			}
			completions: $exts
		}
	}

	def get_handler [input: path] {
		let h = handlers | where ($it.matches | any {|s| $input | str ends-with $s }) | first
		if $h == null {
			error make $'No handler found for extension `($input | get_extension)`'
		}
		return $h
	}

	# List the contents of common archive formats.
	export def list [
		input: path                      # Archive file to read.
		--format (-f): string@extensions # Force use of a particular format instead of guessing based on file extension.
		--raw (-r)                       # Return raw output instead of parsing to a nu table.
	] {
		let f = if ($format | is-not-empty) {
			$'input.($format)'
		} else {
			$input
		}
		let h = get_handler $f
		do $h.list $input $raw
	}

	# Extract common archive formats.
	export def extract [
		input: path            # Archive file to read.
		--directory (-C): path # Directory to extract to. Will be created if it does not exist. Uses default of underlying program if unset, which is usually the current directory.
	] {
		let h = get_handler $input
		if $directory != null { mkdir $directory }
		do $h.extract $input $directory
	}

	# Create an archive in a common format. Format is determined by the extension of the first argument.
	export def create [
		archive: path   # Path to file archive to create. If a file already exists at this path it may be overwritten.
		...inputs: glob # Files to include in the archive.
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
		tmux list-windows -t $effective_session
		| parse '{name}: {title} ({paneCount} panes) [{width}x{height}]{_}'
		| get name
		| into int
		| last
		| each {|i| $i + 1 }
	}

	mut pane = 0
	tmux new-window -t $'($effective_session):($effective_window)' -n 'tplex' -d
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

# Update packages from various providers.
def pkgup [
	--mise-tools (-t) # Update globally installed mise tools
	--mise-self  (-m) # Update mise itself
	--flatpak    (-f) # Update flatpak apps
	--brew       (-b) # Update brew packages
	--system     (-s) # Update the OS using the system package manager
	--all        (-a) # Apply updates of all types. Overrides all other options
] {
	if $mise_self or $all {
		mise self-update -y
	}
	if $mise_tools or $all {
		cd ~/
		mise up
	}
	if $nu.os-info.name == linux and ($flatpak or $all) and (which flatpak | is-not-empty) {
		flatpak update -y
	}
	if ($brew or $all) and (which brew | is-not-empty) {
		brew upgrade --formulae -y
	}
	if ($system or $all) {
		if $nu.os-info.name == 'macos' {
			brew upgrade --casks -y
		} else if $nu.os-info.name == 'linux' {
			if (which ujust | is-not-empty) {
				ujust upgrade
			} else if (which paru | is-not-empty) {
				sudo pacman -Syu --noconfirm
				paru -Su
			} else if (which dnf | is-not-empty) {
				sudo dnf update -y
			} else if (which apt-get | is-not-empty) {
				sudo sh -c 'apt-get update && apt-get upgrade -y'
			} else {
				error make 'Cannot determine system package manager'
			}
		}
	}
}

# Nu wrapper around the Unix `df` command.
def ndf []: nothing -> table<filesystem: string, size: filesize, used: filesize, avail: filesize, used_percent: string, mounted: string> {
	df -h
	| detect columns --guess
	| rename filesystem size used avail used_percent mounted
	| update size { into filesize }
	| update used { into filesize }
	| update avail { into filesize }
}

# Edit neovim configuration.
def 'config nvim' [] {
	nvim ~/.config/nvim/init.lua
}

# Edit git configuration.
def 'config git' [] {
	nvim ~/.gitconfig
}

# Edit atuin configuration.
def 'config atuin' [] {
	nvim ~/.config/atuin/config.toml
}

# Edit mise config
def 'config mise' [--global (-g)] {
	let target = if $global {
		'~/.config/mise/config.toml' | path expand
	} else {
		let cfgs = mise config ls -J | from json
		if ($cfgs | length) < 2 {
			error make 'No local mise config found, pass -g to edit global.'
		}
		$cfgs | first | get path | path expand
	}
	nvim $target
}

