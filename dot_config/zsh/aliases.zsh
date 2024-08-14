alias reload-zsh="source ~/.zshrc"
alias edit-zsh="code ~/.zshrc"
alias cls="clear"
alias c="code"
alias g="git"
alias omp="oh-my-posh"

# if has eza; then
#   TIME_FORMAT="'+%d %b %Y  %H:%M:%S'"
#   GLOB_TO_IGNORE="'.DS_Store|ntuser*|NTUSER*'"
#   EZA_OPTS=(--group --group-directories-first --icons=always --colour=always --level=1 --time-style=$TIME_FORMAT -I $GLOB_TO_IGNORE)

#   alias l="eza -lh $EZA_OPTS"
# 	alias ls="eza -l $EZA_OPTS"
# 	alias ll="eza -lagh $EZA_OPTS"
#   alias ld="eza -lhD $EZA_OPTS"
#   alias lt="eza --tree $EZA_OPTS"
# else
# 	alias ls='ls -A --color=auto'
# 	alias ll='ls -lAg --color=auto'
# fi

if has lsd; then
  alias ls='lsd -l'
  alias ll='lsd -lA'
  alias lA='lsd -lA --total-size'
  alias lt='lsd --tree --depth 1'
else
  alias ls='ls -A --color=auto'
  alias ll='ls -lAg --color=auto'
fi
