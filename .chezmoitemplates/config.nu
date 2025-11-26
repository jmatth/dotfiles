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
# always shown.
# This setting only applies to SQLite-backed history
$env.config.history.isolation = true

if not ($env.SHELL | str ends-with /nu) {
    $env.SHELL = $nu.current-exe
}

let isroot = (id -u | into int) == 0

def 'theme get' []: nothing -> string {
    if $nu.os-info.name == macos {
        if (^defaults read -g AppleInterfaceStyle | complete).exit_code == 1 {
            return 'light'
        } else {
            return 'dark'
        }
    }
    return 'dark'
}

def 'theme generate' [light: bool]: nothing -> record {
    mut theme = {
        palette: {
            base03:   'light_black'
            base02:   'black'
            sec:      (if $light { 'light_cyan' } else { 'light_green' })
            pri:      (if $light { 'light_yellow' } else { 'light_blue' })
            emp:      (if $light { 'light_green' } else { 'light_cyan' })
            base2:    'white'
            base3:    'light_white'
            yellow:   'yellow'
            orange:   'light_red'
            red:      'red'
            magenta:  'magenta'
            violet:   'light_magenta'
            blue:     'blue'
            cyan:     'cyan'
            green:    'green'
        },
    }
    if ($env | get -o COLORTERM) in ['truecolor' '24bit'] {
        $theme.palette.base03  = '#002b36'
        $theme.palette.base02  = '#073642'
        $theme.palette.sec     = (if $light { '#93a1a1' } else { '#586e75' })
        $theme.palette.pri     = (if $light { '#657b83' } else { '#839496' })
        $theme.palette.emp     = (if $light { '#586e75' } else { '#93a1a1' })
        $theme.palette.base2   = '#eee8d5'
        $theme.palette.base3   = '#fdf6e3'
        $theme.palette.yellow  = '#b58900'
        $theme.palette.orange  = '#cb4b16'
        $theme.palette.red     = '#dc322f'
        $theme.palette.magenta = '#d33682'
        $theme.palette.violet  = '#6c71c4'
        $theme.palette.blue    = '#268bd2'
        $theme.palette.cyan    = '#2aa198'
        $theme.palette.green   = '#859900'
    }

    $theme.ansi_mapping = {
        0:  '073642'
        1:  'dc322f'
        2:  '859900'
        3:  'b58900'
        4:  '268bd2'
        5:  'd33682'
        6:  '2aa198'
        7:  'eee8d5'
        8:  '002b36'
        9:  'cb4b16'
        A: '586e75'
        B: '657b83'
        C: '839496'
        D: '6c71c4'
        E: '93a1a1'
        F: 'fdf6e3'
    }

    $theme.color_config = {
        separator: $theme.palette.sec
        leading_trailing_space_bg: (if $light { $theme.palette.base2 } else { $theme.palette.base02 })
        header: $theme.palette.sec
        date: $theme.palette.violet
        filesize: $theme.palette.blue
        row_index: $theme.palette.cyan
        bool: $theme.palette.red
        int: $theme.palette.sec
        duration: $theme.palette.red
        range: $theme.palette.red
        float: $theme.palette.red
        string: $theme.palette.sec
        nothing: $theme.palette.red
        binary: $theme.palette.red
        cellpath: $theme.palette.red
        hints: $theme.palette.sec

        # shape_garbage: { fg: $base07 bg: $red attr: b } # base16 white on red
        # but i like the regular white on red for parse errors
        shape_garbage: { fg: $theme.palette.red attr: r }
        shape_bool: $theme.palette.blue
        shape_int: $theme.palette.violet
        shape_float: $theme.palette.violet
        shape_range: $theme.palette.yellow
        shape_internalcall: $theme.palette.magenta
        shape_external: $theme.palette.emp
        shape_externalarg: $theme.palette.pri
        shape_literal: $theme.palette.blue
        shape_operator: $theme.palette.yellow
        shape_signature: $theme.palette.sec
        shape_string: $theme.palette.sec
        shape_filepath: $theme.palette.blue
        shape_globpattern: $theme.palette.blue
        shape_variable: $theme.palette.violet
        shape_flag: $theme.palette.blue
        shape_custom: { attr: b }

        search_result: { fg: $theme.palette.green attr: r }
    }

    return $theme
}

def 'theme update-console' [ansi_mapping: record, light: bool]: nothing -> nothing {
    if $env.term != 'linux' { return }
    $ansi_mapping | items {|num, hex|
        print -rn $'(ansi osc)P($num)($hex)'
    }
    if $light {
        print -rn $'(ansi bg_white)(ansi black)(ansi esc)[8]'
    } else {
        print -rn $'(ansi bg_black)(ansi white)(ansi esc)[8]'
    }
}

# Change color theme to dark.
def --env 'theme set dark' []: nothing -> nothing {
    let theme = theme generate false
    $env.config.color_config = $theme.color_config
    $env.LS_COLORS = $"(vivid generate solarized-dark)"
    theme update-console $theme.ansi_mapping false
    return
}
# Change color theme to light.
def --env 'theme set light' []: nothing -> nothing {
    let theme = theme generate true
    $env.config.color_config = $theme.color_config
    $env.LS_COLORS = $"(vivid generate solarized-light)"
    theme update-console $theme.ansi_mapping true
    return
}
# Automatically change the theme to match the system
def --env 'theme set auto' [] {
    if (theme get) == light {
        theme set light
    } else {
        theme set dark
    }
}
theme set auto

if $env.TERM == 'linux' {
    $env.config.table.mode = 'single'
}

$env.config.render_right_prompt_on_last_line = true

$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.cursor_shape.vi_normal = "block"
$env.config.cursor_shape.vi_insert = "block"

# The prompt indicators are environmental variables that represent
# the state of the prompt
let solarized = theme generate false
let promptchar = if $isroot { $'(ansi {fg: $solarized.palette.red, attr: rb})#(ansi rst)' } else { '%' }
$env.PROMPT_INDICATOR = $'($promptchar)(ansi $solarized.palette.blue)>(ansi reset) '
$env.PROMPT_INDICATOR_VI_INSERT = $'($promptchar)(ansi $solarized.palette.blue)>(ansi reset) '
$env.PROMPT_INDICATOR_VI_NORMAL = $'($promptchar)(ansi red)[(ansi reset) '
$env.PROMPT_MULTILINE_INDICATOR = '::: '

$env.config.menus ++= [{
    name: history_menu
    only_buffer_difference: true                                    # Search is done on the text written after activating the menu
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
}]

$env.config.menus ++= [{
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
}]

$env.CARAPACE_MATCH = 'CASE_INSENSITIVE'
$env.CARAPACE_EXCLUDES = 'nvim,vim,vi'
let carapace_completer = {|spans|
  # if the current command is an alias, get it's expansion
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
    $env.SSH_AUTH_SOCK = $'(gpgconf --list-dirs agent-ssh-socket)'
    $env.GPG_TTY = ^tty
}

# Do some nonsense to work around nu's weird parse time design choices
const user_autoload = $nu.user-autoload-dirs.0
mkdir $user_autoload

if (which starship | is-not-empty) {
    $env.STARSHIP_SHELL = "nu"
    let starship_path = $user_autoload | path join "starship.nu"
    if not ($starship_path | path exists) {
        starship init nu | save -f $starship_path
    }
}

if (which mise | is-not-empty) {
    let mise_path = $user_autoload | path join mise.nu
    if not ($mise_path | path exists) {
        ^mise activate nu | save -f $mise_path
    }
}

if (which zoxide | is-not-empty) {
    let zoxide_path = $user_autoload | path join "zoxide.nu"
    if not ($zoxide_path | path exists) {
        zoxide init nushell | save -f $zoxide_path
    }
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

# Start Kanata
def kk [] {
    sudo kanata -n -c $"($env.HOME)/.kanata.kdb"
}

# Create a directory and cd into it
def --env mkcd [dir: string] {
    if ($dir | str length) < 1 {
        return
    }
    mkdir $dir
    cd $dir
}

# Move up n directories (default 1)
def --env up [levels: int = 1] {
    if $levels < 1 {
        return
    }
    cd (generate {|i| if $i > 0 { {out: '../', next: ($i - 1)} } } $levels | str join)
}

#
# Git Aliases
#

## Log
# zstyle -s ':prezto:module:git:log:medium' format '_git_log_medium_format' \
#     || _git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'
mut _git_log_medium_format = '%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'
# zstyle -s ':prezto:module:git:log:oneline' format '_git_log_oneline_format' \
#     || _git_log_oneline_format='%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n'
mut _git_log_oneline_format = '%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n'
# zstyle -s ':prezto:module:git:log:brief' format '_git_log_brief_format' \
#     || _git_log_brief_format='%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n'
mut _git_log_brief_format = '%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n'

## Status
# zstyle -s ':prezto:module:git:status:ignore' submodules '_git_status_ignore_submodules' \
#     || _git_status_ignore_submodules='none'
mut _git_status_ignore_submodules = 'none'

# Git
alias g = git

# Branch (b)
alias gb = git branch
alias gba = git branch --all --verbose
alias gbc = git checkout -b
alias gbd = git branch --delete
alias gbD = git branch --delete --force
alias gbl = git branch --verbose
alias gbL = git branch --all --verbose
alias gbm = git branch --move
alias gbM = git branch --move --force
alias gbr = git branch --move
alias gbR = git branch --move --force
alias gbs = git show-branch
alias gbS = git show-branch --all
alias gbv = git branch --verbose
alias gbV = git branch --verbose --verbose
alias gbx = git branch --delete
alias gbX = git branch --delete --force

# Commit (c)
alias gc = git commit --verbose
alias gcS = git commit --verbose --gpg-sign
alias gca = git commit --verbose --all
alias gcaS = git commit --verbose --all --gpg-sign
alias gcm = git commit --message
alias gcmS = git commit --message --gpg-sign
alias gcam = git commit --all --message
alias gco = git checkout
alias gcO = git checkout --patch
alias gcf = git commit --amend --reuse-message HEAD
alias gcfS = git commit --amend --reuse-message HEAD --gpg-sign
alias gcF = git commit --verbose --amend
alias gcFS = git commit --verbose --amend --gpg-sign
alias gcp = git cherry-pick --ff
alias gcP = git cherry-pick --no-commit
alias gcr = git revert
alias gcR = git reset "HEAD^"
alias gcs = git show
alias gcsS = git show --pretty=short --show-signature
alias gcl = git-commit-lost
alias gcy = git cherry --verbose --abbrev
alias gcY = git cherry --verbose

# Conflict (C)
alias gCl = git --no-pager diff --name-only --diff-filter=U
# alias gCa = git add $(gCl)
# alias gCe = git mergetool $(gCl)
alias gCo = git checkout --ours --
# alias gCO = gCo $(gCl)
alias gCt = git checkout --theirs --
# alias gCT = gCt $(gCl)

# Data (d)

# List all files in repo.
def "ngit ls-files" [] {
    (
        git ls-files -tcdmo |
        parse '{status} {name}'|
        update status {|r|
            match $r.status {
            H => 'unmodified',           # tracked file that is not either unmerged or skip-worktree
            S => 'skip-worktree',        # tracked file that is skip-worktree
            M => 'unmerged',             # tracked file that is unmerged
            R => 'removed',              # tracked file with unstaged removal/deletion
            C => 'modified',             # tracked file with unstaged modification/change
            K => 'untracked conflicting' # untracked paths which are part of file/directory conflicts which prevent checking out tracked files
            ? => 'untracked'             # untracked file
            U => 'resolve-undo'          # file with resolve-undo information
            _ => 'UNKNOWN',
        }} |
        metadata set -l
    )
}
alias ngd = ngit ls-files
alias gd  = git ls-files
alias gdc = git ls-files --cached
alias gdx = git ls-files --deleted
alias gdm = git ls-files --modified
alias gdu = git ls-files --other --exclude-standard
alias gdk = git ls-files --killed
alias gdi = git status --porcelain --short --ignored | sed -n "s/^!! //p"

# Fetch (f)
alias gf = git fetch
alias gfa = git fetch --all
alias gfc = git clone
alias gfcr = git clone --recurse-submodules
alias gfm = git pull
alias gfma = git pull --autostash
alias gfr = git pull --rebase
alias gfra = git pull --rebase --autostash

# Flow (F)
alias gFi = git flow init
alias gFf = git flow feature
alias gFb = git flow bugfix
alias gFl = git flow release
alias gFh = git flow hotfix
alias gFs = git flow support

alias gFfl = git flow feature list
alias gFfs = git flow feature start
alias gFff = git flow feature finish
alias gFfp = git flow feature publish
alias gFft = git flow feature track
alias gFfd = git flow feature diff
alias gFfr = git flow feature rebase
alias gFfc = git flow feature checkout
alias gFfm = git flow feature pull
alias gFfx = git flow feature delete

alias gFbl = git flow bugfix list
alias gFbs = git flow bugfix start
alias gFbf = git flow bugfix finish
alias gFbp = git flow bugfix publish
alias gFbt = git flow bugfix track
alias gFbd = git flow bugfix diff
alias gFbr = git flow bugfix rebase
alias gFbc = git flow bugfix checkout
alias gFbm = git flow bugfix pull
alias gFbx = git flow bugfix delete

alias gFll = git flow release list
alias gFls = git flow release start
alias gFlf = git flow release finish
alias gFlp = git flow release publish
alias gFlt = git flow release track
alias gFld = git flow release diff
alias gFlr = git flow release rebase
alias gFlc = git flow release checkout
alias gFlm = git flow release pull
alias gFlx = git flow release delete

alias gFhl = git flow hotfix list
alias gFhs = git flow hotfix start
alias gFhf = git flow hotfix finish
alias gFhp = git flow hotfix publish
alias gFht = git flow hotfix track
alias gFhd = git flow hotfix diff
alias gFhr = git flow hotfix rebase
alias gFhc = git flow hotfix checkout
alias gFhm = git flow hotfix pull
alias gFhx = git flow hotfix delete

alias gFsl = git flow support list
alias gFss = git flow support start
alias gFsf = git flow support finish
alias gFsp = git flow support publish
alias gFst = git flow support track
alias gFsd = git flow support diff
alias gFsr = git flow support rebase
alias gFsc = git flow support checkout
alias gFsm = git flow support pull
alias gFsx = git flow support delete

# Grep (g)
alias gg = git grep
alias ggi = git grep --ignore-case
alias ggl = git grep --files-with-matches
alias ggL = git grep --files-without-matches
alias ggv = git grep --invert-match
alias ggw = git grep --word-regexp

# Index (i)
alias gia = git add
alias giA = git add --patch
alias giu = git add --update
alias gid = git diff --no-ext-diff --cached
alias giD = git diff --no-ext-diff --cached --word-diff
alias gii = git update-index --assume-unchanged
alias giI = git update-index --no-assume-unchanged
alias gir = git reset
alias giR = git reset --patch
alias gix = git rm -r --cached
alias giX = git rm -r --force --cached

# Log (l)
alias gl = git log --topo-order --pretty=format:$"($_git_log_medium_format)"
alias gls = git log --topo-order --stat --pretty=format:$"($_git_log_medium_format)"
alias gld = git log --topo-order --stat --patch --full-diff --pretty=format:$"($_git_log_medium_format)"
alias glo = git log --topo-order --pretty=format:$"($_git_log_oneline_format)"
alias glg = git log --topo-order --graph --pretty=format:$"($_git_log_oneline_format)"
alias glb = git log --topo-order --pretty=format:$"($_git_log_brief_format)"
alias glc = git shortlog --summary --numbered
alias glS = git log --show-signature

# Merge (m)
alias gm = git merge
alias gmC = git merge --no-commit
alias gmF = git merge --no-ff
alias gma = git merge --abort
alias gmt = git mergetool

# Push (p)
alias gp = git push
alias gpf = git push --force-with-lease
alias gpF = git push --force
alias gpa = git push --all
alias gpA = git push --all and git push --tags
alias gpt = git push --tags
# alias gpc = git push --set-upstream origin "$(git-branch-current 2> /dev/null)"
# alias gpp = git pull origin "$(git-branch-current 2> /dev/null)" and git push origin "$(git-branch-current 2> /dev/null)"

# Rebase (r)
alias gr = git rebase
alias gra = git rebase --abort
alias grc = git rebase --continue
alias gri = git rebase --interactive
alias grs = git rebase --skip

# Remote (R)
alias gR = git remote
alias gRl = git remote --verbose
# List git remotes.
def "ngit remote" [] {
    git remote -v | lines | parse "{name}\t{url} ({type})"
}
alias ngRl = ngit remote
alias gRa = git remote add
alias gRx = git remote rm
alias gRm = git remote rename
alias gRu = git remote update
alias gRp = git remote prune
alias gRs = git remote show
alias gRb = git-hub-browse

# Stash (s)
alias gs = git stash
alias gsa = git stash apply
alias gsx = git stash drop
alias gsX = git-stash-clear-interactive
alias gsl = git stash list
alias gsL = git-stash-dropped
alias gsd = git stash show --patch --stat
alias gsp = git stash pop
alias gsr = git-stash-recover
alias gss = git stash save --include-untracked
alias gsS = git stash save --patch --no-keep-index
alias gsw = git stash save --include-untracked --keep-index

# Submodule (S)
alias gS = git submodule
alias gSa = git submodule add
alias gSf = git submodule foreach
alias gSi = git submodule init
alias gSI = git submodule update --init --recursive
alias gSl = git submodule status
alias gSm = git-submodule-move
alias gSs = git submodule sync
alias gSu = git submodule update --remote --recursive
alias gSx = git-submodule-remove

# Tag (t)
alias gt = git tag
alias gtl = git tag --list
alias gts = git tag --sign
alias gtv = git verify-tag

# Working Copy (w)

# Show working tree status.
def "ngit status" [] {
    (
        git status --porcelain=v1 |
        parse --regex '(?<status>..) (?<name>.*)' |
        move name --first |
        upsert staged false |
        update staged {|r|
            if $r.status == '??' {
                return false
            }
            let stchars = $r.status | split chars
            let staged = $stchars.0 != ' '
            let unstaged = $stchars.1 != ' '
            if $staged and $unstaged {
                return 'mixed'
            } else if $staged {
                return true
            } else {
                return false
            }
        } |
        update status {|r|
            match $r.status {
            '??' => 'untracked',
            'A ' => 'added'
            ' M' | 'M ' | 'MM' => 'modified',
            'D ' => 'deleted',
            _ => 'UNKNOWN',
        }} |
        metadata set -l
    )
}
alias ngws = ngit status
alias gwS = git status --ignore-submodules=$"($_git_status_ignore_submodules)" --short
alias gws = git status --ignore-submodules=$"($_git_status_ignore_submodules)"
alias gwd = git diff --no-ext-diff
alias gwD = git diff --no-ext-diff --word-diff
alias gwr = git reset --soft
alias gwR = git reset --hard
alias gwc = git clean --dry-run
alias gwC = git clean --force
alias gwx = git rm -r
alias gwX = git rm -r --force
# alias gwt = cd ${$(git rev-parse --show-cdup):-.}'

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
