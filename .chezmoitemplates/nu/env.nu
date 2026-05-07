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

$env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
	"XDG_DATA_DIRS": {
		from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
		to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
	}
	"LD_LIBRARY_PATH": {
		from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
		to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
	}
	"PKG_CONFIG_PATH": {
		from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
		to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
	}
}

$env.NU_LIB_DIRS ++= [
	($nu.default-config-dir | path join modules)
]
