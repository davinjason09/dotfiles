alias l  = ls -lhX
alias ll = ls -lahX
alias lt = ls -lahX --tree

# ╾╼ EDITOR ╾──────────────────────────────────────────────────────────╼
alias n = nvim
alias v = nvim
alias vi = nvim

def lazyvim [...args] {
  with-env { NVIM_APPNAME: "lazyvim" } {
    nvim ...$args
  }
}
