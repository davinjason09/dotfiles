# TODO: setup completion menu and completers

$env.CARAPACE_BRIDGES = "inshellisense,carapace,zsh,fish,bash"

$env.config.completions.algorithm = "substring"

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
  | update value {|row|
    let value = $row.value
    let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
    if ($need_quote and ($value | path exists)) {
      let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
      $'"($expanded_path | str replace --all "\"" "\\\"")"'
    } else {$value}
  }
}

let carapace_completer = {|spans: list<string>|
  carapace $spans.0 nushell ...$spans
  | from json
  | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

let zoxide_completer = {|spans|
  $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
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

  match $spans.0 {
    # carapace completions are incorrect for nu
    nu => $fish_completer
    # fish completes commits and branch names in a nicer way
    git => $fish_completer
    # use zoxide completions for zoxide commands
    __zoxide_z | __zoxide_zi | z | zi => $zoxide_completer
    _ => $carapace_completer
  } | do $in $spans
}

$env.config.completions.external = {
  enable: true
  max_results: 100
  completer: $external_completer
}
