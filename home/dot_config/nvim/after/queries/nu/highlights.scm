; extends

; Use @keyword.repeat instead of @keyword for "for" for consistency with the conditionals
(ctrl_for
  "for" @keyword.repeat)

; Use @variable.parameter instead of @attribute for parameter flags
[
  (attribute_identifier)
  (long_flag_identifier)
  (param_short_flag_identifier)
  (short_flag_identifier)
] @variable.parameter

"finally" @keyword.exception
