alias reload-zsh="znap restart"
alias edit-zsh="$EDITOR ~/.zshrc"
alias n="nvim"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias lg="lazygit"
alias g="git"
alias pwsh="cmd.exe /c start /min pwsh"
alias edit="msedit"
alias open="xdg-open"

alias lazyvim="NVIM_APPNAME=lazyvim nvim"

if has eza; then
  GLOB_TO_IGNORE="'.DS_STORE|*ntuser*|*NTUSER*'"
  EZA_OPTS=(--git --group-directories-first --icons=always --color=always --level=1 --time-style="'+%Y-%m-%d %H:%M:%S'" -I $GLOB_TO_IGNORE)

  alias l="eza -lhX $EZA_OPTS"
  alias ls="eza -lX $EZA_OPTS"
  alias ll="eza -lAhX $EZA_OPTS"
  alias lt="eza --tree $EZA_OPTS"
else
  alias ls="ls --color=auto"
  alias ll="ls -lAg --color=auto"
fi
