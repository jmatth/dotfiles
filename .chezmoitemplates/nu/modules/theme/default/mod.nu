const palette = {
    standard: {
        primary:   'white'
        secondary: 'white_dimmed'
        red:       'red'
        green:     'green'
        yellow:    'yellow'
        blue:      'blue'
        magenta:   'magenta'
        cyan:      'cyan'
    }
}

export def generate [light: bool] {
    return {
        palette: {
            standard: {
                primary:   if $light { 'black' } else { 'white' }
                secondary: if $light { 'black_dimmed' } else { 'white_dimmed' }
                red:       'red'
                green:     'green'
                yellow:    'yellow'
                blue:      'blue'
                magenta:   'magenta'
                cyan:      'cyan'
            }
            ansi_mapping: {
                0:  '000000'
                1:  'c40000'
                2:  '00c400'
                3:  'c47e00'
                4:  '0000c4'
                5:  'c400c4'
                6:  '00c4c4'
                7:  'c4c4c4'
                8:  '4e4e4e'
                9:  'dc4e4e'
                A:  '4edc4e'
                B:  'f3f34e'
                C:  '4e4edc'
                D:  'f34ef3'
                E:  '4ef3f3'
                F:  'ffffff'
            }
        }
        color_config: {
            separator: default
            leading_trailing_space_bg: { attr: n }
            header: green_bold
            empty: blue
            bool: light_cyan
            int: default
            filesize: cyan
            duration: default
            datetime: purple
            range: default
            float: default
            string: default
            nothing: default
            binary: default
            cell-path: default
            row_index: green_bold
            record: default
            list: default
            closure: green_bold
            glob:cyan_bold
            block: default
            hints: dark_gray
            search_result: { bg: red fg: default }
            shape_binary: purple_bold
            shape_block: blue_bold
            shape_bool: light_cyan
            shape_closure: green_bold
            shape_custom: green
            shape_datetime: cyan_bold
            shape_directory: cyan
            shape_external: cyan
            shape_externalarg: green_bold
            shape_external_resolved: light_yellow_bold
            shape_filepath: cyan
            shape_flag: blue_bold
            shape_float: purple_bold
            shape_glob_interpolation: cyan_bold
            shape_globpattern: cyan_bold
            shape_int: purple_bold
            shape_internalcall: cyan_bold
            shape_keyword: cyan_bold
            shape_list: cyan_bold
            shape_literal: blue
            shape_match_pattern: green
            shape_matching_brackets: { attr: u }
            shape_nothing: light_cyan
            shape_operator: yellow
            shape_pipe: purple_bold
            shape_range: yellow_bold
            shape_record: cyan_bold
            shape_redirection: purple_bold
            shape_signature: green_bold
            shape_string: green
            shape_string_interpolation: cyan_bold
            shape_table: blue_bold
            shape_variable: purple
            shape_vardecl: purple
            shape_raw_string: light_purple
            shape_garbage: {
                fg: default
                bg: red
                attr: b
            }
        }
    }
}
