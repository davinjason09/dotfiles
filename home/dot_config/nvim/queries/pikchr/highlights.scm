; --- Keywords & Built-ins ---
(objectClass) @keyword

(direction) @keyword

(numericProperty) @property

[
  "define"
  "print"
  "assert"
  "same"
  "same as"
  "behind"
  "go"
  "until"
  "even"
  "with"
  "from"
  "to"
  "of"
  "the"
  "way"
  "between"
  "and"
  "heading"
  "close"
  "last"
  "previous"
] @keyword

; --- Functions & Macros ---
(statement
  "define" @keyword.function
  macroName: (VARIABLE) @function
  macroDefinition: (CODEBLOCK) @markup.raw.block
  (#set! priority 101))

(macroCall
  macroName: (VARIABLE) @function.call)

[
  "abs"
  "cos"
  "dist"
  "int"
  "max"
  "min"
  "sin"
  "sqrt"
] @function.builtin

; --- Literals & Values ---
(NUMBER) @number

(STRING) @string

(COLORNAME) @constant.builtin

(ORDINAL) @number

; --- Identifiers ---
(LABEL) @label

(VARIABLE) @variable

; --- Operators & Punctuation ---
[
  "+"
  "-"
  "*"
  "/"
  "=="
  "="
  "+="
  "-="
  "*="
  "/="
  "<-"
  "->"
  "<->"
] @operator

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  "."
  ","
  ":"
  ";"
] @punctuation.delimiter

; --- Comments & Extras ---
(comments) @comment @spell
