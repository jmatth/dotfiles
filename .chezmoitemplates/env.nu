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
