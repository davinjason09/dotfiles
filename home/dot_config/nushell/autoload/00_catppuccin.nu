let theme = {
  rosewater: "#F5E0DC"
  flamingo: "#F2CDCD"
  pink: "#F5C2E7"
  mauve: "#CBA6F7"
  red: "#F38BA8"
  maroon: "#EBA0AC"
  peach: "#FAB387"
  yellow: "#F9E2AF"
  green: "#A6E3A1"
  teal: "#94E2D5"
  sky: "#89DCEB"
  sapphire: "#74C7EC"
  blue: "#89B4FA"
  lavender: "#B4BEFE"
  text: "#CDD6F4"
  subtext1: "#BAC2DE"
  subtext0: "#A6ADC8"
  overlay2: "#9399B2"
  overlay1: "#7F849C"
  overlay0: "#6C7086"
  surface2: "#585B70"
  surface1: "#45475A"
  surface0: "#313244"
  base: "#1E1E2E"
  mantle: "#181825"
  crust: "#11111B"
}

let scheme = {
  recognized_command: { fg: $theme.blue attr: b }
  unrecognized_command: { fg: $theme.red attr: b }
  constant: $theme.peach
  punctuation: $theme.overlay2
  operator: $theme.sky
  string: $theme.green
  virtual_text: $theme.surface2
  variable: { fg: $theme.rosewater attr: i }
  filepath: $theme.yellow
}

$env.config.color_config = {
  separator: { fg: $theme.surface2 attr: b }
  leading_trailing_space_bg: { fg: $theme.lavender attr: u }
  header: { fg: $theme.text attr: b }
  row_index: $scheme.virtual_text
  record: $theme.text
  list: $theme.text
  hints: $scheme.virtual_text
  search_result: { fg: $theme.base bg: $theme.yellow }
  shape_closure: $theme.teal
  closure: $theme.teal
  shape_flag: { fg: $theme.maroon attr: i }
  shape_matching_brackets: { attr: u }
  shape_garbage: $theme.red
  shape_keyword: $theme.mauve
  shape_match_pattern: $theme.green
  shape_signature: $theme.teal
  shape_table: $scheme.punctuation
  cell-path: $scheme.punctuation
  shape_list: $scheme.punctuation
  shape_record: $scheme.punctuation
  shape_vardecl: $scheme.variable
  shape_variable: $scheme.variable
  empty: { attr: n }
  filesize: {||
    if $in < 1kb {
      $theme.teal
    } else if $in < 10kb {
      $theme.green
    } else if $in < 100kb {
      $theme.yellow
    } else if $in < 10mb {
      $theme.peach
    } else if $in < 100mb {
      $theme.maroon
    } else if $in < 1gb {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  duration: {||
    if $in < 1day {
      $theme.teal
    } else if $in < 1wk {
      $theme.green
    } else if $in < 4wk {
      $theme.yellow
    } else if $in < 12wk {
      $theme.peach
    } else if $in < 24wk {
      $theme.maroon
    } else if $in < 52wk {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  date: {|| (date now) - $in |
    if $in < 1day {
      $theme.teal
    } else if $in < 1wk {
      $theme.green
    } else if $in < 4wk {
      $theme.yellow
    } else if $in < 12wk {
      $theme.peach
    } else if $in < 24wk {
      $theme.maroon
    } else if $in < 52wk {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  shape_external: $scheme.unrecognized_command
  shape_internalcall: $scheme.recognized_command
  shape_external_resolved: $scheme.recognized_command
  shape_block: $scheme.recognized_command
  block: $scheme.recognized_command
  shape_custom: $theme.pink
  custom: $theme.pink
  background: $theme.base
  foreground: $theme.text
  cursor: { bg: $theme.rosewater fg: $theme.base }
  shape_range: $scheme.operator
  range: $scheme.operator
  shape_pipe: $scheme.operator
  shape_operator: $scheme.operator
  shape_redirection: $scheme.operator
  glob: $scheme.filepath
  shape_directory: $scheme.filepath
  shape_filepath: $scheme.filepath
  shape_glob_interpolation: $scheme.filepath
  shape_globpattern: $scheme.filepath
  shape_int: $scheme.constant
  int: $scheme.constant
  bool: {|x| if $x { $theme.green } else { $theme.red } }
  float: $scheme.constant
  nothing: $scheme.constant
  binary: $scheme.constant
  shape_nothing: $scheme.constant
  shape_bool: $scheme.constant
  shape_float: $scheme.constant
  shape_binary: $scheme.constant
  shape_datetime: $scheme.constant
  shape_literal: $scheme.constant
  string: $scheme.string
  shape_string: $scheme.string
  shape_string_interpolation: $theme.flamingo
  shape_raw_string: $scheme.string
  shape_externalarg: $theme.rosewater
}

$env.config.highlight_resolved_externals = true
$env.config.explore = {
  status_bar_background: { fg: $theme.text, bg: $theme.crust },
  command_bar_text: { fg: $theme.text },
  highlight: { fg: $theme.base, bg: $theme.yellow },
  status: {
    error: $theme.red,
    warn: $theme.yellow,
    info: $theme.sky,
  },
  selected_cell: { bg: $theme.sky fg: $theme.base },
}

$env.LS_COLORS = (vivid generate catppuccin-mocha)
