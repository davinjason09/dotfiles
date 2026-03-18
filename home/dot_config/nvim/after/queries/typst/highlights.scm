; extends

([
  "for"
  "while"
  "break"
  "continue"
] @keyword.repeat
  (#set! priority 130))

([
  "if"
  "else"
] @keyword.conditional
  (#set! priority 130))

(for
  "in" @keyword.repeat
  (#set! priority 130))

(code
  "#" @keyword.repeat
  [
    (for)
    (branch)
    (while)
  ]
  (#set! priority 130))

((bool) @boolean
  (#set! priority 130))
