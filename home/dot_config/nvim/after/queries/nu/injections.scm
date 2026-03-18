; extends

(command
  head: (cmd_identifier) @injection.language
  flag: (short_flag
    name: (short_flag_identifier) @_flag
    (#eq? @_flag "c"))
  arg: [
    (val_string
      (string_content) @injection.content)*
    (val_interpolated
      (escaped_interpolated_content) @injection.content)*
  ])

(command
  flag: (long_flag)
  arg_str: (val_string) @injection.language
  flag: (short_flag
    name: (short_flag_identifier) @_flag
    (#eq? @_flag "c"))
  arg: [
    (val_string
      (string_content) @injection.content)*
    (val_interpolated
      (escaped_interpolated_content) @injection.content)*
  ])
