# Use yazi to change directory
def --env yz [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)

	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
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
      | split row "\n"
      | split column " "
      | get column1
      | where {|x| $x not-in $parts }
    )
  }
}

# Yeet package with style 😎
def yeet [...packages: list<string>@yeet-completer] {
  let all_packages: list<string> = yay -Q | split row "\n" | split column " " | get column1
  mut removed_packages = []

  if ($packages | is-not-empty) {
    for package in $packages {
      if ($all_packages | where $it == $package | is-not-empty) {
        $removed_packages = $removed_packages | append $package
      } else {
        gum log --level warn $"($package) is not installed, skipping..."
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
    gum log --level info "No package to remove, exiting..."
    return
  }

  let formatted = $removed_packages | each {|x| $"- ($x)\n" } | str join ""
  $"# Package to remove:\n($formatted)" | gum format
  print "\n"

  try {
    gum confirm --default=no "Do you want to remove these packages?"
    yay -Rns ($removed_packages | str join " ")
  } catch {
    gum log --level info "\nCancelling..."
  }
}
