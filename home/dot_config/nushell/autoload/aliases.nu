alias nu-ls = %ls

alias reload = exec nu
alias lg = lazygit
alias g = git
alias nu-open = open
alias core-ls = ls
alias open = xdg-open
let IGNORE_GLOB = "'.DS_STORE|*ntuser*|*NTUSER*'"
let EZA_OPTS = [ --git --group-directories-first --icons=always --color=always --time-style '+%Y-%m-%d %H:%M:%S' -I $IGNORE_GLOB ]

alias l = eza -lhX ...$EZA_OPTS
alias ls = eza -lX ...$EZA_OPTS
alias ll = eza -lahX ...$EZA_OPTS
alias lt = eza -lahXTL1 ...$EZA_OPTS

alias y = yazi
