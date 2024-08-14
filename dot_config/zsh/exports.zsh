export FZF_DEFAULT_OPTS='
  --color=fg:#cdd6f4,fg+:#d0d0d0,bg:-1,bg+:#262626
  --color=hl:#f38ba8,hl+:#5fd7ff,info:#cba6f7,marker:#f5e0dc
  --color=prompt:#cba6f7,spinner:#f5e0dc,pointer:#f5e0dc,header:#f38ba8
  --color=border:#585b70,label:#aeaeae,query:#d9d9d9 --ansi
  --border=top --prompt=" " --layout=reverse --cycle
  --marker="" --pointer="󰜴" --separator="─" --scrollbar="│" --height=~80%
'

export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git --color always --fixed-strings --path-separator //'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git --color always --fixed-strings --path-separator //'

export FZF_CTRL_T_OPTS="
  --preview '$show_file_or_dir_preview'
  --padding=0,1,0
  --preview-window=right:50%:border-left
  --bind='ctrl-/:change-preview-window(hidden|)'
"

export FZF_ALT_C_OPTS='
  --preview "eza --tree --level=1 --color=always  --icons=always {} | head -200"
  --padding=0,1,0
  --preview-window=right:50%:border-left
  --prompt="Directory  "
'
