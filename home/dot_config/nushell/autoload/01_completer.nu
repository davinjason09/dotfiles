$env.ARGC_SHELL_PATH = (which nu | get path | to text | str trim)
$env.ARGC_COMPLETIONS_ROOT = ($nu.default-config-dir | path join "argc-completions")
$env.ARGC_COMPLETIONS_PATH = ($env.ARGC_COMPLETIONS_ROOT + '/completions/linux' + ':' + $env.ARGC_COMPLETIONS_ROOT + '/completions' + ":" + $nu.default-config-dir + "/completions")

$env.config.completions = {
  algorithm: "substring"
  case_sensitive: false
}

def argc-generate [cmd: string] {
  bash ($env.ARGC_COMPLETIONS_ROOT + "/scripts/generate.sh") $cmd | save -f ($nu.default-config-dir + "/completions/" + $cmd + ".sh")
}

# ╾╼ Menus ╾───────────────────────────────────────────────────────────╼
let menus = [
  {
    name: completion_menu
    only_buffer_difference: false
    marker: $env.PROMPT_INDICATOR
    type: {
      layout: ide
      min_completion_width: 0
      max_completion_width: 150
      max_completion_height: 25
      padding: 0
      border: false
      cursor_offset: 0
      description_mode: "prefer_right"
      min_description_width: 0
      max_description_width: 50
      max_description_height: 10
      description_offset: 1
      correct_cursor_pos: false
    }
    style: {
      text: $theme.sky
      selected_text: { fg: $theme.base bg: $theme.sky attr: b }
      description_text: $theme.lavender
      match_text: { attr: u }
      selected_match_text: { attr: ur }
    }
  }
]

$env.config.menus = $env.config.menus
| where name not-in ($menus | get name)
| append $menus

# ╾╼ Completers ╾──────────────────────────────────────────────────────╼
let fish_completer = {|spans|
  fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
  | from tsv --flexible --noheaders --no-infer
  | rename value description
  | take while {|row| ($row.value | split row " " | length) == 1 } # NOTE: remove value if it contains more than 1 word
  | update value {|row|
    let value = $row.value
    let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
    if ($need_quote and ($value | path exists)) {
      let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
      $'"($expanded_path | str replace --all "\"" "\\\"")"'
    } else { $value }
  }
}

let zoxide_completer = {|spans|
  $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
}

let yeet_completer = {|spans|
  let packages = ($spans | skip 1)
  let cur_prompt = ($spans | last)

  yay -Q
  | lines
  | split column " "
  | get column0
  | where {|x| $x not-in ($packages) and ($x | str contains $cur_prompt)}
}

let argc_completer = {|spans|
  argc --argc-compgen nushell "" ...$spans
  | split row "\n"
  | each {|line| $line | split column "\t" value description }
  | flatten
}

let external_completer = {|spans|
  let expanded_alias = scope aliases
  | where name == $spans.0
  | get -o 0.expansion

  let spans = if $expanded_alias != null {
    $spans
    | skip 1
    | prepend ($expanded_alias | split row ' ' | take 1)
  } else {
    $spans
  }

  let fish_cmd = [
    git chezmoi bat gum yay mise nvim bob cowsay cowthink
    pdflatex latex sudo
  ]

  let zoxide_cmd = [
    __zoxide_z __zoxide_zi
  ]

  match $spans.0 {
    $cmd if ($cmd in $fish_cmd) => $fish_completer
    $cmd if ($cmd in $zoxide_cmd) => $zoxide_completer
    yeet => $yeet_completer
    _ => $argc_completer
  } | do $in $spans
}

$env.config.completions.external = {
  enable: true
  max_results: 100
  completer: $external_completer
}
