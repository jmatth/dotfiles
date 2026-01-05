# Detect the system theme, either "light" or "dark".
# Returns "dark" by default if system theme cannot be determined.
export def 'fetch' []: nothing -> string {
    if $nu.os-info.name == macos {
        if (^defaults read -g AppleInterfaceStyle | complete).exit_code == 1 {
            return 'light'
        } else {
            return 'dark'
        }
    }
    return 'dark'
}

export def 'generate' [light: bool]: nothing -> record {
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
        A:  '586e75'
        B:  '657b83'
        C:  '839496'
        D:  '6c71c4'
        E:  '93a1a1'
        F:  'fdf6e3'
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
        hints: { pri: $theme.palette.sec attr: d }

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

# Change color theme to dark.
export def --env 'set dark' []: nothing -> nothing {
    let theme = generate false
    $env.config.color_config = $theme.color_config
    $env.LS_COLORS = $"(vivid generate solarized-dark)"
    update-console $theme.ansi_mapping false
    return
}
# Change color theme to light.
export def --env 'set light' []: nothing -> nothing {
    let theme = generate true
    $env.config.color_config = $theme.color_config
    $env.LS_COLORS = $"(vivid generate solarized-light)"
    update-console $theme.ansi_mapping true
    return
}
# Automatically change the theme to match the system
export def --env 'set auto' [] {
    if (fetch) == light {
        set light
    } else {
        set dark
    }
}
