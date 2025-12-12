; extends

(math
  (formula)) @indent.auto

(math
  "$" @indent.begin
  (_)*
  "$" @indent.end
  (#set! indent.immediate 1))

[
  (block)
  (group)
  (tagged
    (content))
  (group
    (content))
  (code
    (content))
  (math)
] @indent.begin

[
  (item
    (text))
  (comment)
  (ERROR)
] @indent.auto

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
  "$"
] @indent.branch

[
  ")"
  "]"
  "}"
  "$"
] @indent.end
