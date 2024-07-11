if (!(Get-Command -Name "eza" -ErrorAction SilentlyContinue)) {
  return
}

$DEFAULT_EZA_ARGS = @(
  "--color=always",
  "--git",
  "--group-directories-first",
  "--icons=always",
  "--ignore-glob=.DS_Store|ntuser*|NTUSER*",
  "--no-quotes",
  "--sort=type",
  "--level=1",
  "--modified",
  "--time-style=+%d %b %Y  %H:%M:%S "
)

function _ls {
  eza -l @DEFAULT_EZA_ARGS @args
}

function l {
  eza -lh @DEFAULT_EZA_ARGS @args
}

function ll {
  eza -lagh @DEFAULT_EZA_ARGS @args
}

function ld {
  eza -lDh @DEFAULT_EZA_ARGS @args
}

function lt {
  eza --tree @DEFAULT_EZA_ARGS @args
}

Set-Alias -Name ls -Value _ls -Force