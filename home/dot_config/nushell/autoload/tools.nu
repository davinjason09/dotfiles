# Use yazi to change directory
def --env yz [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)

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

def cc [file: string] {
  let clang_ver = clang --version | lines | parse --regex '(\d+)' | get capture0.0
  (
    zig c++
      -O3
      -Wall
      -Wno-vla-cxx-extension
      -std=c++20
      -march=native
      -fsanitize=address
      -L$"/usr/lib/clang/($clang_ver)/lib/linux/"
      -lclang_rt.asan-x86_64
      $file
  )
}

def yeet-completer [context: string] {
  let parts = $context | split row " " | skip 1
  {
    options: {
      sort: true,
      completion_algorithm: substring,
      case_sensitive: false,
    },
    completions: (
      yay -Q
      | lines
      | split column " "
      | get column0
      | where {|x| $x not-in $parts }
    )
  }
}

# Yeet package with style 😎
def yeet [...packages: string@yeet-completer] {
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
    GUM_FORMAT_THEME: ($nu.home-path | path join ".config" "glamour" "catppuccin.json")
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

    yay -Rns ($removed_packages | str join " ")
  } catch {
    with-env { GUM_LOG_LEVEL_FOREGROUND: $theme.sky } {
      gum log --level info "\nCancelling..."
    }
  }
}
