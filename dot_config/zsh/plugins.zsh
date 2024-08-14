#  load syntax-highlighting, completions, and autosuggestions -------------------
zinit ice depth=1 && zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting \
  blockf \
  zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions

# General Plugins
zinit light wfxr/forgit
zinit light lincheney/fzf-tab-completion
zinit light jirutka/zsh-shift-select
zinit light RobSis/zsh-completion-generator
# zinit light Aloxaf/fzf-tab

# zinit cdreplay -q
