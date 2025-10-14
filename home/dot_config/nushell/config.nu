source functions.nu
source aliases.nu
source catppuccin.nu

$env.config.show_banner = false
$env.config.highlight_resolved_externals = true
$env.config.buffer_editor = "nvim"
$env.config.render_right_prompt_on_last_line = true

$env.TRANSIENT_PROMPT_COMMAND = {|| $"\n(^starship module -s $env.LAST_EXIT_CODE character)" }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| $"(ansi yellow)(get_clock_icon) (date now | format date '%R')(ansi reset)" }
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| ^starship prompt --continuation }

