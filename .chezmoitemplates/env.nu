# env.nu
#
# Installed by:
# version = "0.106.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.
use std/util "path add"

$env.NU_LIB_DIRS ++= [($nu.home-path)/.config/nushell/modules]
# Generate nu module to handle mise integration. Probably won't work on initial
# install so this is mainly here to make periodically regenerating the module
# easier.
def 'mise nugen' []: nothing -> nothing {
    mise activate nu | save -f ~/.config/nushell/modules/mise.nu
}

# Need to use an absolute path here because parse time keywords are annoying.
use ~/.config/nushell/modules/mise.nu

if (uname).kernel-name == 'Darwin' {
    path add '/opt/homebrew/sbin'
    path add '/opt/homebrew/bin'
}

if (uname).kernel-name == 'Linux' {
    let omarchy_bin_path = ($env.HOME | path join .local share omarchy bin)
    if ($omarchy_bin_path | path exists) {
        path add $omarchy_bin_path
    }
}

let cargohome = $"($env.HOME)/.cargo"
if ($cargohome | path exists) {
    path add $'($cargohome)/bin'
}
