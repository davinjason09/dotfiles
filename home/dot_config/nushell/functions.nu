def has [command] {
  which $command | is-not-empty
}

def --env "path add" [paths] {
  $env.PATH = ($env.PATH | split row (char esep) | prepend $paths | uniq)
}

alias core-ls = ls

def ls [
  --all (-a),         # Show hidden files
  --long (-l),        # Get all available columns for each entry (slower; columns are platform-dependent)
  --tree (-T),        # Show a tree view of directories
  --du (-d),          # Display the apparent directory size ("disk usage") in the place of the directory metadata size
  --full-paths (-f),  # display paths as absolute paths
  --directory (-D),   # List the specified directory itself instead of its contents
  --header (-h),      # Show the header row
  --dereference (-X)  # Dereference symbolic links when displaying information
  --structured (-S)   # Whether to structure the output as a table
  ...pattern: glob    # The glob pattern to use
]: [nothing -> table] {
  let pattern = if ($pattern | is-empty) { [ '.' ] } else { $pattern }
  mut DEFAULT_EZA_ARGS = [
    "--git"
    "--group-directories-first"
    "--icons"
    "--color"
    "--level=1"
    "--time-style=+%Y-%m-%d %H:%M:%S"
    "-I '.DS_STORE|*ntuser*|*NTUSER*'"
  ]

  if $structured {
    (core-ls
      --all=$all
      --long=$long
      --du=$du
      --full-paths=$full_paths
      --directory=$directory
      ...$pattern
    )
  } else {
    if $long { $DEFAULT_EZA_ARGS = $DEFAULT_EZA_ARGS | append "-l" }
    if $all { $DEFAULT_EZA_ARGS = $DEFAULT_EZA_ARGS | append "-a" }
    if $directory { $DEFAULT_EZA_ARGS = $DEFAULT_EZA_ARGS | append "-D" }
    if $tree { $DEFAULT_EZA_ARGS = $DEFAULT_EZA_ARGS | append "--tree" }
    if $header { $DEFAULT_EZA_ARGS = $DEFAULT_EZA_ARGS | append "-h" }
    if $du { $DEFAULT_EZA_ARGS = $DEFAULT_EZA_ARGS | append "--total-size" }
    if $full_paths { $DEFAULT_EZA_ARGS = $DEFAULT_EZA_ARGS | append "--absolute" }

    eza -lX ...$DEFAULT_EZA_ARGS ...$pattern
  }
}

def get-clock-icon []: [nothing -> string] {
  ["" "" "" "" "" "" "" "" "" "" "" ""]
  | get ((
    date now
    | format date '%l'
    | into int
  ) - 1)
}

def get-git-root []: [nothing -> string] {
  git rev-parse --show-toplevel | complete | get stdout | str trim
}

def get-title []: [nothing -> string] {
  mut path: string = $env.PWD
  let git_dir = get-git-root

  if ($git_dir | is-not-empty) {
    let prefix = $" ($git_dir | split row '/' | last)"
    $path = ($path | str replace $git_dir $prefix)
  }

  $path = $path | str replace $env.HOME ~

  mut split = $path | split row "/"
  if ($split.0 | is-empty) and ($split.0 != ~) {
    $split = $split | drop nth 0
    $split.0 = "/" + $split.0
  }

  if (($split | length) > 3) {
    return $"($split.0)/…/($split | last 2 | str join '/')"
  }

  $path
}
