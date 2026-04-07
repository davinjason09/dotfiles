; extends

(context) @indent.begin

(math
  (formula)) @indent.auto

(math
  "$" @indent.begin
  (_)*
  "$" @indent.end
  (#set! indent.immediate 1))

[
  ")"
  "]"
  "}"
  "$"
] @indent.end @indent.branch

[
  (item
    (text))
  (comment)
  (ERROR)
] @indent.auto

((ERROR
  (call)) @indent.begin
  (#set! indent.immediate 1))
