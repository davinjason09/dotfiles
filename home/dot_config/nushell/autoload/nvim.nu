def nvim [
  ...paths: path      # file arguments to open nvim
  -t: string          # [tag]: a tag, looked up in tags file and the match is chosen.
  -q: path            # [errorfile]: open in quickfix mode with the name of an errorfile
  --app (-A): string  # [cfgfile]: Use NVIM_APPNAME [cfgfile]
  --cmd: string       # [cmd]: Execute <cmd> before any config
  -c: string          # [cmd]: Execute <cmd> after config and first file
  -l: string          # [script]: Execute Lua <script> (with optional args)
  -S: string          # [session]: Source <session> after loading the first file
  -s: string          # [scriptin]: Read Normal mode commands from <scriptin>
  -u: path            # [cfgfile]: Use config [cfgfile]
  -d                  # Diff mode
  --es                # Silent (batch) mode
  --help (-h)         # Print this help message
  -i: path            # [shada]: Use shada file [shada]
  -n                  # No swap file, use memory only
  -o: int             # [N]: Open N windows (default: one per file)
  -O: int             # [N]: Open N vertical windows (default: one per file)
  -p: int             # [N]: Open N tab pages (default: one per file)
  -R                  # Read-only (view) mode
  --version (-v)      # Print version informgtion
  -V: int             # [level]: Verbose [level]
  --api-info          # Write msgpack-encoded API metadata to stdout
  --clean             # "Factory defaults" (skip user config and plugins, shada)
  --embed             # Use stdin/stdout as a msgpack-rpc channel
  --headless          # Don't start a user interface
  --listen: string    # [address]: Serve RPC API from [address]
  --remote            # Execute commands remotely on a server
  --server: string    # [server]: Specify RPC [server] to send commands to
  --startuptime: path # [file]: Write startup timing messages to [file]
] {
  let setup_socat = not ($es and $embed and $headless and $help)
  mut args = []

  if $d        { $args = ($args | append "-d") }
  if $es       { $args = ($args | append "--es") }
  if $help     { $args = ($args | append "--help") }
  if $n        { $args = ($args | append "-n") }
  if $R        { $args = ($args | append "-R") }
  if $version  { $args = ($args | append "--version") }
  if $api_info { $args = ($args | append "--api-info") }
  if $clean    { $args = ($args | append "--clean") }
  if $embed    { $args = ($args | append "--embed") }
  if $headless { $args = ($args | append "--headless") }
  if $remote   { $args = ($args | append "--remote") }

  if ($t | is-not-empty)           { $args = ($args | append "-t" | append $t) }
  if ($q | is-not-empty)           { $args = ($args | append "-q" | append $q) }
  if ($cmd | is-not-empty)         { $args = ($args | append "--cmd" | append $cmd) }
  if ($c | is-not-empty)           { $args = ($args | append "-c" | append $c) }
  if ($l | is-not-empty)           { $args = ($args | append "-l" | append $l) }
  if ($S | is-not-empty)           { $args = ($args | append "-S" | append $S) }
  if ($s | is-not-empty)           { $args = ($args | append "-s" | append $s) }
  if ($u | is-not-empty)           { $args = ($args | append "-u" | append $u) }
  if ($i | is-not-empty)           { $args = ($args | append "-i" | append $i) }
  if ($o | is-not-empty)           { $args = ($args | append "-o" | append $o) }
  if ($O | is-not-empty)           { $args = ($args | append "-O" | append $O) }
  if ($p | is-not-empty)           { $args = ($args | append "-p" | append $p) }
  if ($V | is-not-empty)           { $args = ($args | append "-V" | append $V) }
  if ($listen | is-not-empty)      { $args = ($args | append "--listen" | append $listen) }
  if ($server | is-not-empty)      { $args = ($args | append "--server" | append $server) }
  if ($startuptime | is-not-empty) { $args = ($args | append "--startuptime" | append $startuptime) }

  $args = ($args | append $paths)

  if (ps | where name == socat | is-empty) and $setup_socat {
    let ipc_path = '/tmp/discord-ipc-0'

    if ($ipc_path | path exists) { rm -f $ipc_path }

    let exec_arg = $"EXEC:($env.WIN_HOME)/bin/npiperelay.exe //./pipe/discord-ipc-0"
    let socat_args = [$"UNIX-LISTEN:($ipc_path),fork" $"($exec_arg)"]
    job spawn { ^socat ...$socat_args | complete | ignore }

    print "Started socat for Discord IPC"
  }

  let args = $args
  with-env { NVIM_APPNAME: $app } { ^nvim ...$args }
}

def rm_nvim_cache [appname: string] {
  try { rm -r $'($env.XDG_DATA_HOME)/($appname)' }
  try { rm -r $'($env.XDG_STATE_HOME)/($appname)' }
  try { rm -r $'($env.XDG_CACHE_HOME)/($appname)' }
}

alias n = nvim
alias v = nvim
alias vi = nvim
alias lazyvim = nvim --app "lazyvim"
alias ntest = nvim --app "nvim-test"
