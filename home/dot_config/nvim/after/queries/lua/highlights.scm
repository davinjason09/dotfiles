; extends

; ╾╼ Highlight some globals as @namespace.builtin ╾──────────────────────╼
; Taken from:
; https://github.com/LazyVim/LazyVim/blob/main/queries/lua/highlights.scm
((identifier) @namespace.builtin
  (#any-of? @namespace.builtin "vim" "Snacks" "Utils" "Defaults")
  (#set! "priority" 130))

(dot_index_expression
  table: (identifier) @namespace.builtin
  field: (identifier)
  (#any-of? @namespace.builtin "vim" "Snacks" "Utils" "Defaults")
  (#set! "priority" 130))

; ╾╼ Highlight as @property even if the value is a function ╾──────────╼
; NOTE:
; score higher than 128 as the debug hl override priority is 128, this is to ensure the property field
; always use the @property highlight no matter if the identifier matched any of the @module.builtin
(field
  name: (identifier) @property
  (#set! "priority" 130))

; ╾╼ Set 2nd argument of `vim.split` and `vim.gsplit` to regex ╾─────────╼
; Taken from: https://github.com/ribru17/.dotfiles/blob/master/.config/nvim/queries/lua/highlights.scm
(function_call
  name: (dot_index_expression) @_method
  arguments: (arguments
    .
    (_)
    .
    (string
      (string_content) @string.regexp))
  (#any-of? @_method "vim.split" "vim.gsplit"))

; ╾╼ Emmylua highlight override ╾─────────────────────────────────────────╼
((identifier) @module.builtin
  (#any-of? @module.builtin "_G" "debug" "io" "jit" "math" "os" "package" "string" "table" "utf8")
  (#set! "priority" 128))

(function_declaration
  [
    "function"
    "end"
  ] @keyword.function
  (#set! "priority" 126))

(function_definition
  [
    "function"
    "end"
  ] @keyword.function
  (#set! "priority" 126))

(do_statement
  [
    "do"
    "end"
  ] @keyword
  (#set! "priority" 126))

(while_statement
  [
    "while"
    "do"
    "end"
  ] @keyword.repeat
  (#set! "priority" 126))

(repeat_statement
  [
    "repeat"
    "until"
  ] @keyword.repeat
  (#set! "priority" 126))

(if_statement
  [
    "if"
    "elseif"
    "else"
    "then"
    "end"
  ] @keyword.conditional
  (#set! "priority" 126))

(elseif_statement
  [
    "elseif"
    "then"
    "end"
  ] @keyword.conditional
  (#set! "priority" 126))

(else_statement
  [
    "else"
    "end"
  ] @keyword.conditional
  (#set! "priority" 126))

(for_statement
  [
    "for"
    "do"
    "end"
  ] @keyword.repeat
  (#set! "priority" 126))

([
  (false)
  (true)
] @boolean
  (#set! "priority" 126))

((nil) @constant.builtin
  (#set! "priority" 126))

([
  "and"
  "not"
  "or"
] @keyword.operator
  (#set! "priority" 126))

("return" @keyword.return
  (#set! "priority" 126))

(ERROR
  [
    "if"
    "for"
    "while"
    "do"
  ] @keyword.conditional
  (#set! "priority" 126))
