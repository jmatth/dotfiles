export def generate [light: bool] {
  mut theme = {
    palette: {
      internal: {
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
      }
      standard: {
        primary:   'white'
        secondary: 'white'
        red:       'red'
        green:     'green'
        yellow:    'yellow'
        blue:      'blue'
        magenta:   'magenta'
        cyan:      'cyan'
      }
      ansi_mapping: {
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
    }
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

  $theme.color_config = {
    separator: $theme.palette.internal.sec
    leading_trailing_space_bg: (if $light { $theme.palette.internal.base2 } else { $theme.palette.base02 })
    header: $theme.palette.internal.sec
    date: $theme.palette.internal.violet
    filesize: $theme.palette.internal.blue
    row_index: $theme.palette.internal.cyan
    bool: $theme.palette.internal.red
    int: $theme.palette.internal.sec
    duration: $theme.palette.internal.red
    range: $theme.palette.internal.red
    float: $theme.palette.internal.red
    string: $theme.palette.internal.sec
    nothing: $theme.palette.internal.red
    binary: $theme.palette.internal.red
    cellpath: $theme.palette.internal.red
    hints: { pri: $theme.palette.internal.sec attr: d }

    # shape_garbage: { fg: $base07 bg: $red attr: b } # base16 white on red
    # but i like the regular white on red for parse errors
    shape_garbage: { fg: $theme.palette.internal.red attr: r }
    shape_bool: $theme.palette.internal.blue
    shape_int: $theme.palette.internal.violet
    shape_float: $theme.palette.internal.violet
    shape_range: $theme.palette.internal.yellow
    shape_internalcall: $theme.palette.internal.magenta
    shape_external: $theme.palette.internal.emp
    shape_externalarg: $theme.palette.internal.pri
    shape_literal: $theme.palette.internal.blue
    shape_operator: $theme.palette.internal.yellow
    shape_signature: $theme.palette.internal.sec
    shape_string: $theme.palette.internal.sec
    shape_filepath: $theme.palette.internal.blue
    shape_globpattern: $theme.palette.internal.blue
    shape_variable: $theme.palette.internal.violet
    shape_flag: $theme.palette.internal.blue
    shape_custom: { attr: b }

    search_result: { fg: $theme.palette.internal.green attr: r }
  }

  return $theme
}
