use ./rose_pine
use ./solarized

export-env {
    $env.nu_color_theme = {
        dark: 'rose-pine-moon'
        light: 'rose-pine-dawn'
    }
}

# Detect the system theme, either "light" or "dark".
# Returns "dark" by default if system theme cannot be determined.
export def 'fetch mode' []: nothing -> string {
    if $nu.os-info.name == macos {
        if (^defaults read -g AppleInterfaceStyle | complete).exit_code == 1 {
            return 'light'
        } else {
            return 'dark'
        }
    }
    return 'dark'
}

export def 'fetch name' []: nothing -> string {
    if (fetch mode) == light {
        return $env.nu_color_theme.dark
    } else {
        return $env.nu_color_theme.light
    }
}

export def fetch [name: string]: nothing -> record {
    let theme = match $name {
        'solarized-dark'  => (solarized generate false)
        'solarized-light' => (solarized generate true)
        'rose-pine'       => (rose_pine generate false false)
        'rose-pine-moon'  => (rose_pine generate false true)
        'rose-pine-dawn'  => (rose_pine generate true false)
    }
    return $theme
}

export def 'fetch auto' []: nothing -> record {
    return (fetch (fetch name))
}

# Set the colors of the linux console.
export def 'update-console' [ansi_mapping: record, light: bool]: nothing -> nothing {
    if $env.TERM? != 'linux' { return }
    $ansi_mapping | items {|num, hex|
        print -rn $'(ansi osc)P($num)($hex)'
    }
    if $light {
        print -rn $'(ansi bg_white)(ansi black)(ansi esc)[8]'
    } else {
        print -rn $'(ansi bg_black)(ansi white)(ansi esc)[8]'
    }
}

# Change color theme
export def --env set [name: string]: nothing -> nothing {
    let theme = fetch $name
    $env.config.color_config = $theme.color_config
    if (which vivid | is-not-empty) {
        $env.LS_COLORS = $"(vivid generate $name)"
    }
    let light = $name in [solarized-light rose-pine-dawn]
    update-console $theme.palette.ansi_mapping $light
}

# Automatically change the theme
export def --env 'set auto' [] {
    if (fetch mode) == light {
        set $env.nu_color_theme.dark
    } else {
        set $env.nu_color_theme.light
    }
}
