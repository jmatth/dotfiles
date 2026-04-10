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

path add ($nu.home-dir | path join .local bin)
path add ($nu.home-dir | path join .pixi bin)
path add ($nu.home-dir | path join .cargo bin)

$env.NU_LIB_DIRS ++= [
    ($nu.default-config-dir | path join modules)
]

const mise_mod_path = $nu.default-config-dir | path join modules mise.nu

use $mise_mod_path
# Mise doesn't run the full env update code on activation. Retreive it as the
# most recently added pre_prompt hook and run it manually so $env.PATH is
# populated for future config files.
do --env ($env.config.hooks.pre_prompt | last | get code)
