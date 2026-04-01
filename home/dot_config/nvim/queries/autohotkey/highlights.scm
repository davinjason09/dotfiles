; --- Identifiers & Fallback ---
(identifier) @variable

; --- Comments ---
(line_comment) @comment

(block_comment) @comment

(directive_comment) @comment

; --- Literals ---
(string_literal) @string

(multiline_string_literal) @string

(continuation_section) @string

(integer_literal) @number

(float_literal) @number

(hex_literal) @number

(boolean_literal) @constant.builtin

(unset) @constant.builtin

; --- Keywords (Control Flow) ---
; These nodes represent the actual keyword tokens in the v2 grammar
[
  (if)
  (else)
  (while)
  (for)
  (in)
  (loop)
  (until)
  (try)
  (catch)
  (finally)
  (return)
  (throw)
  (goto)
  (break)
  (continue)
  (as)
  (switch)
  (case)
  (default)
] @keyword

; Specialized loop keywords
[
  (parse)
  (read)
  (files)
  (reg)
] @keyword

; --- Keywords (Declarations & Scopes) ---
[
  (class)
  (extends)
  (get)
  (set)
  (scope_identifier)
] @keyword

; --- Function & Method Declarations ---
(function_declaration
  name: (identifier) @function)

(method_declaration
  name: (identifier) @function.method)

; Parameters
(param_sequence
  (identifier) @variable.parameter)

(default_param
  name: (identifier) @variable.parameter)

(variadic_param
  name: (identifier) @variable.parameter)

(byref_param
  "&" @operator)

; Meta-functions (fixed regex)
(method_declaration
  name: (identifier) @function.special
  (#match? @function.special "\\v\\c^__(New|Delete|Get|Set|Call)$"))

; --- Calls & Access ---
(function_call
  function: (identifier) @function.call)

(call_statement
  function: (identifier) @function.call)

; Object member access (e.g., obj.property)
(member_access
  member: (identifier) @property)

(call_statement
  function: (member_access
    member: (identifier) @function.method.call))

; Property/Literal keys
(property_declaration
  name: (identifier) @property)

(object_literal_member
  key: (identifier) @property)

; Built-in Functions (Fixed regex)
; ((function_call
;   function: (identifier) @function.builtin)
;   (#match? @function.builtin
;     "\\v\\c^(MsgBox|StrLen|SubStr|RegExMatch|RegExReplace|Array|Object|Map|Integer|Float|String|IsSet|VarSetStrCapacity|DllCall|NumGet|NumPut|ObjBindMethod|WinActive|WinExist|WinClose|Run|RunWait|FileRead|FileAppend|SetTimer|Sleep|ExitApp|Reload)$"))
; --- Operators ---
(assignment_operator) @operator

(bitshift_operator) @operator

(arrow) @operator

(wildcard) @operator

[
  "?"
  ":"
  "!"
  "~"
  "+"
  "-"
  "*"
  "/"
  "//"
  "**"
  "&"
  "^"
  "|"
  "<<"
  ">>"
  ">>>"
  "="
  "=="
  "!="
  "!=="
  "<"
  ">"
  "<="
  ">="
  "~="
  "??"
  "."
] @operator

; Verbal Operators (and, or, not, is)
(verbal_not_operation
  operator: _ @keyword.operator)

(logical_and_operation
  operator: _ @keyword.operator)

(logical_or_operation
  operator: _ @keyword.operator)

(type_check_operation
  operator: _ @keyword.operator)

; --- Hotkeys & Remaps ---
(hotkey_trigger) @string.special

(hotkey_and) @operator

(hotkey_win) @operator

(key_identifier) @type

; Meta modifiers (~ and $)
(hotkey_nonblocking) @operator

(hotkey_usehook) @punctuation.special

; AltTab commands
[
  (hotkey_alttab)
  (hotkey_shiftalttab)
  (hotkey_alttabmenu)
  (hotkey_alttabandmenu)
  (hotkey_alttabmenudismiss)
] @keyword

; --- Hotstrings ---
(hotstring
  ":" @punctuation.delimiter
  "::" @punctuation.delimiter)

(hotstring_trigger) @string.special

(hotstring_option_sequence) @attribute

(hotstring_replacement) @string

; --- Directives (All v2 variants) ---
(directive_identifier) @attribute

(directive_arguments) @string.special

[
  (clipboard_timeout_directive)
  (dll_load_directive)
  (error_stdout_directive)
  (requires_directive)
  (hotif_directive)
  (hotif_timeout_directive)
  (hotstring_directive)
  (include_directive)
  (include_again_directive)
  (input_level_directive)
  (use_hook_directive)
  (max_threads_directive)
  (max_threads_per_hotkey_directive)
  (max_threads_buffer_directive)
  (no_tray_icon_directive)
  (single_instance_directive)
  (warn_directive)
] @keyword.directive

; Special cases within directives
(encoding_identifier) @constant

(single_instance_mode) @constant

(warning_type) @constant

(warning_mode) @constant

(version_requirement) @number

; --- Special Variables (A_*) ---
((identifier) @variable.builtin
  (#match? @variable.builtin "\\v\\c^A_"))

; --- Punctuation ---
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  "."
  ":"
] @punctuation.delimiter

(dereference_operation
  "%" @punctuation.special)

(varref_operation
  "&" @punctuation.special)
