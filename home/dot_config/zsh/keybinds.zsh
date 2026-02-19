#!/usr/bin/env zsh

# ╾╼ Keybindings ╾─────────────────────────────────────────────────────╼
export KEYTIMEOUT=15

bindkey -e

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[C' forward-char
bindkey '^[[D' backward-char
bindkey '^[[F' end-of-line
bindkey '^[[H' beginning-of-line

bindkey '^[z' undo
bindkey '^U' backward-kill-line
bindkey '^H' backward-kill-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
