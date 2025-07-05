# ╾╼ Cache path ╾──────────────────────────────────────────────────────╼
zcachedir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/cache"
zcompdump="$zcachedir/compcache"
_comp_dumpfile="$zcompdump"
[ -d $zcachedir ] || mkdir -p "$zcachedir" > /dev/null

# ╾╼ Completion Settings ╾─────────────────────────────────────────────╼
setopt ALWAYS_TO_END          # Complete to end of word.
setopt COMPLETE_IN_WORD       # Complete in words.
setopt COMPLETE_ALIASES       # Complete aliases.
setopt EXTENDEDGLOB           # Disable extended glob syntax.
setopt GLOB_COMPLETE          # Enable glob matching for completion.
setopt GLOBDOTS               # Include hidden files in globbing.
unsetopt MENU_COMPLETE        # Do not auto select the first completion entry.

zstyle '*:compinit' arguments -u -C -w
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$zcompdump"

# HACK:
# since znap do the compinit for us, using `_comp_options+=(globdots)` doesn't add it to the list
# so we need to add it manually, and at the moment the best I can think of is to add it in the precmd hook
# this will ensure that `globdots` is always added to the completion options and will not be duplicated
_add_globdots() {
  _comp_options=("${(@u)_comp_options}")
  if [[ -n "$_comp_options" && ! "${_comp_options[(r)globdots]}" ]]; then
    _comp_options+=('globdots')
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _add_globdots

# ╾╼ Completions ╾─────────────────────────────────────────────────────╼
FUNCTION_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"

add_completion() {
  local function="$1"
  local command="$2"

  if (( $+commands[${function}] )) && [ ! -f "$FUNCTION_DIR/_$function" ]; then
    znap fpath "_${function}" "$command"
    znap compile $FUNCTION_DIR
  fi
}

znap install zsh-users/zsh-completions

add_completion gh        'gh completion -s zsh'
add_completion rg        'rg --generate=complete-zsh'
add_completion uv        'uv generate-shell-completion zsh'
add_completion bat       'bat --completion zsh'
add_completion gum       'gum completion zsh'
add_completion uvx       'uvx --generate-shell-completion zsh'
add_completion glow      'glow completion zsh'
add_completion atuin     'atuin gen-completions --shell zsh'
add_completion cargo     'rustup completions zsh cargo'
add_completion delta     'delta --generate-completion zsh'
add_completion gowall    'gowall completion zsh'
add_completion rustup    'rustup completions zsh'
add_completion chezmoi   'chezmoi completion zsh'
add_completion wezterm   'wezterm shell-completion --shell zsh'
add_completion ast-grep  'ast-grep completions zsh'
add_completion starship  'starship completions zsh'

add_completion fd        'curl -fsSL https://raw.githubusercontent.com/sainnhe/zsh-completions/refs/heads/master/src/custom/_fd'
add_completion bun       'curl -fsSL https://raw.githubusercontent.com/oven-sh/bun/refs/heads/main/completions/bun.zsh'
add_completion duf       'curl -fsSL https://raw.githubusercontent.com/LinoWhy/.dotfiles/refs/heads/main/zsh/.config/zsh/completions/_duf'
add_completion eza       'curl -fsSL https://raw.githubusercontent.com/eza-community/eza/refs/heads/main/completions/zsh/_eza'
add_completion fzf       'curl -fsSL https://raw.githubusercontent.com/sainnhe/zsh-completions/refs/heads/master/src/custom/_fzf'
add_completion tldr      'curl -fsSL https://raw.githubusercontent.com/tealdeer-rs/tealdeer/refs/heads/main/completion/zsh_tealdeer'
add_completion tokei     'curl -fsSL https://raw.githubusercontent.com/Aloxaf/dotfiles/refs/heads/master/zsh/.config/zsh/completions/_tokei'
add_completion fastfetch 'curl -fsSL https://raw.githubusercontent.com/fastfetch-cli/fastfetch/refs/heads/dev/completions/fastfetch.zsh'

# compile completions
znap compile $FUNCTION_DIR

# ╾╼ fzf Style ╾───────────────────────────────────────────────────────╼
_fzf_compgen_path() {
  fd . --hidden --exclude=".git" --exclude="node_modules" --color=always --no-ignore-parent "$1"
}

_fzf_compgen_dir() {
  fd . --type=d --hidden --exclude=".git" --exclude="node_modules" --color=always --no-ignore-parent "$1"
}

export FZF_DEFAULT_OPTS="
  --color='
    fg:#CDD6F4,     fg+:#BAC2DE,     bg+:#181825,     bg:-1
    hl:#F38BA8,     hl+:#89DCEB,     info:#89DCEB,    marker:#A6E3A1
    prompt:#F5BDE6, spinner:#F5C2E7, pointer:#F5E0DC, header:#F38BA8
    border:#6C7086, label:#AEAEAE,   query:#CDD6F4
  '
  --ansi --border=top --cycle --layout=reverse
  --prompt=' ' --marker='✓' --marker-multi-line='▖▌▘'
  --pointer='󰁔' --scrollbar='┃' --separator='─'
  --preview-window=right:60%:border-rounded
  --bind='ctrl-d:preview-half-page-down'
  --bind='ctrl-u:preview-half-page-up'
"

export FZF_DEFAULT_COMMAND='fd . --strip-cwd-prefix --exclude=".git" --exclude="node_modules" --color=always --no-ignore-parent --max-depth=1 --unrestricted'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd . --type=d --strip-cwd-prefix --exclude=".git" --exclude="node_modules" --color=always --no-ignore-parent --unrestricted'

export FZF_CTRL_T_OPTS="
  --preview 'bash $HOME/.config/zsh/file-preview.sh {}'
  --padding=0,1,0
  --bind='ctrl-/:change-preview-window(hidden|)'
"

export FZF_ALT_C_OPTS='
  --preview "eza --tree --level=1 --color=always  --icons=always {} | head -200"
  --padding=0,1,0
  --prompt="Directory  "
'

# ╾╼ Completion Styles ╾───────────────────────────────────────────────╼

[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' '+l:|=* r:|=*'
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-grouped true
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# fzf-tab
zstyle ':fzf-tab:*' fzf-min-height 15
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'

zstyle ':fzf-tab:complete:*:*' fzf-preview 'bash $HOME/.config/zsh/file-preview.sh $realpath'
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview

zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  'case $group in
    "[process ID]") ps --pid=$word -o cmd --no-headers -w -w ;;
    "[process-group]") ps --group=$word -o pid,user,comm -w -w ;;
    "[option]") echo "Options: $desc" ;;
    *) echo "" ;;
  esac'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:8:wrap

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -lAXhT -L 1 --group-directories-first --color=always --icons --git --no-user $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -lAXhT -L 1 --group-directories-first --color=always --icons --git --no-user $realpath'
zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:systemctl-(status|(re|)start|(dis|en)able):*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:systemctl-show:*' fzf-preview 'systemctl show $word | bat --color=always -plini'
zstyle ':fzf-tab:complete:tldr:argument-1' fzf-preview 'tldr --color always $word'
zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
  '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || \
   (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out | bat -plman --color=always) || \
   (out=$(which "$word") && echo $out) || echo "${(P)word}"'
