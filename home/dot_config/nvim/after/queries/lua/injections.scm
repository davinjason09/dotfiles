; extends

; ╾╼ Add injection using `-- INJECT: <parser>` ╾─────────────────────────╼
; Taken from: https://github.com/ribru17/.dotfiles/blob/master/.config/nvim/queries/lua/injections.scm
; with modifications
(_
  (comment
    (comment_content) @injection.language)
  .
  (assignment_statement
    (expression_list
      value: (string
        content: (string_content) @injection.content)))
  (#gsub! @injection.language "^ INJECT: ([%w_]+)$" "%1"))

(_
  (comment
    (comment_content) @injection.language)
  .
  (field
    value: (string
      (string_content) @injection.content))
  (#gsub! @injection.language "^ INJECT: ([%w_]+)$" "%1"))

(_
  (comment
    (comment_content) @injection.language)
  .
  (variable_declaration
    (assignment_statement
      [
        (expression_list
          value: (string
            content: (string_content) @injection.content))
        (expression_list
          value: (function_call
            name: (method_index_expression
              table: (parenthesized_expression
                (string
                  (string_content) @injection.content)))))
      ]))
  (#gsub! @injection.language "^ INJECT: ([%w_]+)$" "%1"))

(_
  (table_constructor
    (comment
      (comment_content) @injection.language)
    [
      (field
        name: (_)
        value: (string
          (string_content) @injection.content))
      (field
        value: (string
          content: (string_content) @injection.content))
    ])
  (#gsub! @injection.language "^ INJECT: ([%w_]+)$" "%1"))
