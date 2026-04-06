; extends

((tag
  (name) @keyword
  ":" @punctuation.delimiter)
  .
  "text" @type
  (#eq? @keyword "INJECT")
  (#match? @type "[a-z_<>]")
  (#set! priority 126))
