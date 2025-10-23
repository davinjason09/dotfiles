$env.FZF_DEFAULT_COMMAND = "fd . --strip-cwd-prefix --exclude '.git' --exclude 'node_modules' --color=always --no-ignore-parent --max-depth=1 --unrestricted"
$env.FZF_CTRL_T_COMMAND = $env.FZF_DEFAULT_COMMAND
$env.FZF_ALT_C_COMMAND = "fd . --type=d --strip-cwd-prefix --exclude '.git' --exclude 'node_modules' --color=always --no-ignore-parent --unrestricted"


$env.FZF_DEFAULT_OPTS = "
  --color='
    fg:#CDD6F4,     fg+:#BAC2DE,     bg+:#181825,     bg:-1
    hl:#F38BA8,     hl+:#89DCEB,     info:#89DCEB,    marker:#A6E3A1
    prompt:#F5BDE6, spinner:#F5C2E7, pointer:#F5E0DC, header:#F38BA8
    border:#6C7086, label:#AEAEAE,   query:#CDD6F4
  '
  --ansi --border=top --cycle --layout=reverse
  --prompt=' ' --marker='✓' --marker-multi-line='▖▌▘'
  --pointer='󰁔' --scrollbar='┃' --separator='─'
  --min-height 15 --height 60%
  --preview-window=right:60%:border-rounded
  --bind='ctrl-d:preview-half-page-down'
  --bind='ctrl-u:preview-half-page-up'
"

$env.FZF_CTRL_T_OPTS = "--preview '$HOME/.config/scripts/file_preview {}' --padding=0,1,0 --bind='ctrl-/:change-preview-window(hidden)'"
$env.FZF_ALT_C_OPTS = "--preview 'eza -T --level=1 --color=always --icons=always {} | head -n 200' --padding=0,1,0 --prompt='Directory  '"

# Jump to directory
const alt_c = {
  name: fzf_dirs
  modifier: alt
  keycode: char_c
  mode: [emacs, vi_normal, vi_insert]
  event: [
    {
      send: executehostcommand
      cmd: "
        let fzf_alt_c_command = \$\"($env.FZF_ALT_C_COMMAND) | fzf ($env.FZF_ALT_C_OPTS)\";
        let result = nu -c $fzf_alt_c_command;
        cd $result;
      "
    }
  ]
}

# List files
const ctrl_t =  {
  name: fzf_files
  modifier: control
  keycode: char_t
  mode: [emacs, vi_normal, vi_insert]
  event: [
    {
      send: executehostcommand
      cmd: "
        let fzf_ctrl_t_command = \$\"($env.FZF_CTRL_T_COMMAND) | fzf ($env.FZF_CTRL_T_OPTS)\";
        let result = nu -l -i -c $fzf_ctrl_t_command;
        commandline edit --append $result;
        commandline set-cursor --end
      "
    }
  ]
}

$env.config.keybindings ++= [ $alt_c $ctrl_t ]
