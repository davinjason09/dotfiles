source functions.nu

$env.config.show_banner = false
$env.config.highlight_resolved_externals = true
$env.config.buffer_editor = "nvim"
$env.config.render_right_prompt_on_last_line = true

$env.TRANSIENT_PROMPT_COMMAND = {|| $"\n(^starship module -s $env.LAST_EXIT_CODE character)" }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| $"(ansi yellow)(get_clock_icon) (date now | format date '%R')(ansi reset)" }
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| ^starship prompt --continuation }
$env.config.shell_integration."osc2" = false

# ╾╼ Custom OSC2 integration ╾─────────────────────────────────────────╼
$env.config.hooks.pre_prompt ++= [
  { print -n $"(ansi title)(get-title)(ansi st)" }
]

$env.config.hooks.pre_execution ++= [
  { print -n $"(ansi title)(get-title) - (commandline)(ansi st)" }
]

# ╾╼ Run onefetch only when entering a new git directory ╾─────────────╼

# Don't run onefetch if our entry point is a git directory
$env.LAST_REPO = get-git-root
$env.config.hooks.env_change = {
  PWD: [{
    let git_root = get-git-root
    if ($git_root | is-not-empty) and ($git_root != $env.LAST_REPO ) {
      $env.LAST_REPO = $git_root
      print (onefetch)
    }
  }]
}

