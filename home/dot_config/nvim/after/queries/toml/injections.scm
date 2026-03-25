; extends

; ╾╼ Context ╾───────────────────────────────────────────────────────────╼
; Handle [tasks] and [tasks.name]
; Key: run
((table
  (bare_key) @_table_key
  (#match? @_table_key "^tasks"))
  (pair
    (bare_key) @key
    (#eq? @key "run")
    (string) @injection.content)
  (#is-mise?))

; Handle [tools]
; Key: postinstall (inside an inline_table)
((table
  (bare_key) @_table_key
  (#eq? @_table_key "tools"))
  (pair
    (inline_table
      (pair
        (bare_key) @key
        (#eq? @key "postinstall")
        (string) @injection.content)))
  (#is-mise?))

; Handle [hooks]
; Keys: cd, enter, leave, postinstall, preinstall
((table
  (bare_key) @_table_key
  (#eq? @_table_key "hooks"))
  (pair
    (bare_key) @key
    (#any-of? @key "cd" "enter" "leave" "postinstall" "preinstall")
    (string) @injection.content)
  (#is-mise?))

; ╾╼ Injection Logic ╾───────────────────────────────────────────────────╼
; CASE A: Multiline + Shebang with /env (e.g., #!/usr/bin/env python)
((pair
  (bare_key) @key
  (string) @injection.content @injection.language)
  (#any-of? @key "run" "postinstall" "preinstall" "cd" "enter" "leave")
  (#match? @injection.language "^['\"]{3}\n* #!(/\\w+)+/env\\s+\\w+")
  (#gsub! @injection.language "^.*#!/.*/env%s+([^%s\n]+).*" "%1")
  (#offset! @injection.content 0 3 0 -3))

; CASE B: Multiline + Standard Shebang (e.g., #!/bin/bash)
((pair
  (bare_key) @key
  (string) @injection.content @injection.language)
  (#any-of? @key "run" "postinstall" "preinstall" "cd" "enter" "leave")
  (#match? @injection.language "^['\"]{3}\n* #!(/\\w+)+\\s*\n")
  (#gsub! @injection.language "^.*#!/.*/([^/%s\n]+).*" "%1")
  (#offset! @injection.content 0 3 0 -3))

; CASE C: Multiline WITHOUT Shebang (Default to bash)
((pair
  (bare_key) @key
  (string) @injection.content)
  (#any-of? @key "run" "postinstall" "preinstall" "cd" "enter" "leave")
  (#match? @injection.content "^['\"]{3}")
  (#not-match? @injection.content "^['\"]{3}\n* #!")
  (#set! injection.language "bash")
  (#offset! @injection.content 0 3 0 -3))

; CASE D: Single line (Default to bash)
((pair
  (bare_key) @key
  (string) @injection.content)
  (#any-of? @key "run" "postinstall" "preinstall" "cd" "enter" "leave")
  (#not-match? @injection.content "^['\"]{3}")
  (#set! injection.language "bash")
  (#offset! @injection.content 0 1 0 -1))
