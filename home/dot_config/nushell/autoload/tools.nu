# Custom ls
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

alias l     = ls -lhX
alias ll    = ls -lahX
alias lt    = ls -lahX --tree
alias nu-ls = ls -S

# Use yazi to change directory
def --env yz [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (nu-open $tmp)

	if $cwd != "" and $cwd != $env.PWD { cd $cwd }
	rm -fp $tmp
}

# Upload file to envs.sh
def 0file [file: path] {
  http post https://envs.sh --content-type "multipart/form-data" { file: (open -r $file | into binary) }
}

# Shorten link using envs.sh
def 0short [url: string] {
  http post https://envs.sh --content-type "multipart/form-data" { shorter: $url }
}

def cc [file: path] {
  let clang_ver = clang --version | lines | first | parse --regex '(\d+)' | get capture0.0
  let lib = $"/usr/lib/clang/($clang_ver)/lib/linux/"
  let asan = 'clang_rt.asan-x86_64'

  let args = [ -O3 -Wall -march=native -fsanitize=address -L ($lib) -l ($asan) ($file) ]
  let ext = $file | path parse | get extension

  match $ext {
    c   => { zig cc ...$args }
    cpp => { zig c++ -std=c++20 -Wno-vla-cxx-extension ...$args }
  }
}

def cc_run [file: path] {
  cc $file
  ./a.out
}

def cc_once [file: path] {
  cc_run $file
  try { rm ./a.out }
}

# Yeet package with style 😎
@complete external
def yeet [...packages] {
  let all_packages: list<string> = yay -Q | lines | split column " " | get column0
  mut removed_packages = []

  if ($packages | is-not-empty) {
    for package in $packages {
      if ($all_packages | where $it == $package | is-not-empty) {
        $removed_packages = $removed_packages | append $package
      } else {
        with-env { GUM_LOG_LEVEL_FOREGROUND: $theme.yellow } {
          gum log --level warn $"($package) is not installed, skipping..."
        }
      }
    }
  } else {
    $removed_packages = (
      $all_packages
      | to text
      | fzf --height 15 --multi --preview 'yay -Qi {} | bat -plyaml'
      | lines
    )
  }

  if ($removed_packages | is-empty) {
    with-env { GUM_LOG_LEVEL_FOREGROUND: $theme.sky } {
      gum log --level info "No package to remove, exiting..."
    }
    return
  }

  let formatted = $removed_packages | each {|x| $"- ($x)\n" } | str join ""
  with-env {
    GUM_FORMAT_THEME: ($nu.home-dir | path join ".config" "glamour" "catppuccin.json")
  } {
    $"# Package to remove:\n($formatted)" | gum format
  }

  try {
    with-env {
      GUM_CONFIRM_SELECTED_BACKGROUND: $theme.sky
      GUM_CONFIRM_SELECTED_FOREGROUND: $theme.base
      GUM_CONFIRM_UNSELECTED_BACKGROUND: $theme.surface0
      GUM_CONFIRM_UNSELECTED_FOREGROUND: $theme.text
      GUM_CONFIRM_PROMPT_FOREGROUND: $theme.lavender
    } {
      gum confirm --default=no " Do you want to remove these packages?"
    }

    yay -Rns ...$removed_packages
  } catch {
    with-env { GUM_LOG_LEVEL_FOREGROUND: $theme.sky } {
      gum log --level info "\nCancelling..."
    }
  }
}

@complete external
def --wrapped glazewm [...rest: string] {
  let sub = ($rest | first 2)

  if $sub.0 == command and (($sub | length) > 1 and $sub.1 == clear-stale) {
    ^glazewm query windows
    | from json
    | get data.windows
    | where displayState == hiding
    | each {|x| ^glazewm command --id $x.id ignore | from json }
  } else {
    ^glazewm ...$rest
  }
}
