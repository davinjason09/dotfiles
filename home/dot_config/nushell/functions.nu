def has [command] {
  which $command | is-not-empty
}

def --env "path add" [paths] {
  $env.PATH = ($env.PATH | append $paths | uniq)
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
  let git_dir = $env.LAST_REPO

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

def --env print_onefetch [root: path] {
  if ($env.ONEFETCH_CACHE? | is-empty) { $env.ONEFETCH_CACHE = [] }

  let $cur_commit = do { git rev-parse --short HEAD } | complete | get stdout | str trim
  if ($cur_commit | is-empty) { return }

  let cached_entry = $env.ONEFETCH_CACHE | where path == $root
  if ($cached_entry | is-not-empty) and ($cached_entry.0.commit == $cur_commit) {
    print $cached_entry.0.output
  } else {
    let output = (do { onefetch } | complete | get stdout)
    if ($output | is-empty) { return }

    print $output
    $env.ONEFETCH_CACHE = (
      $env.ONEFETCH_CACHE
      | where path != $root
      | append [[path, commit, output]; [$root, $cur_commit, $output]]
    )
  }
}
