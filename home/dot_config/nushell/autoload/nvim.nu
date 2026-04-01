@complete external
def --wrapped nvim [
  --app (-A): string # [cfgfile]: Use NVIM_APPNAME [cfgfile]
  ...rest: string    # file arguments to open nvim
] {
  let setup_socat = ($rest | split row " " | any {|x| $x in [-Es -es --embed --headless]})

  if (ps | where name == socat | is-empty) and $setup_socat {
    let ipc_path = '/tmp/discord-ipc-0'

    if ($ipc_path | path exists) { rm -f $ipc_path }

    let exec_arg = $"EXEC:($env.WIN_HOME)/bin/npiperelay.exe //./pipe/discord-ipc-0"
    let socat_args = [$"UNIX-LISTEN:($ipc_path),fork" $"($exec_arg)"]
    job spawn { ^socat ...$socat_args | complete | ignore }

    print "Started socat for Discord IPC"
  }

  with-env { NVIM_APPNAME: $app } { ^nvim ...$rest }
}

def rm_nvim_cache [appname: string] {
  try { rm -r $"($env.XDG_DATA_HOME)/($appname)" }
  try { rm -r $"($env.XDG_STATE_HOME)/($appname)" }
  try { rm -r $"($env.XDG_CACHE_HOME)/($appname)" }
}

alias n = nvim
alias v = nvim
alias vi = nvim
alias lazyvim = nvim --app "lazyvim"
alias ntest = nvim --app "nvim-test"
