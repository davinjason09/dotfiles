const path = ($nu.data-dir | path join "vendor/autoload")
mkdir $path

starship init nu                 | save -f ($path | path join "starship.nu")
zoxide init nushell --cmd cd     | save -f ($path | path join "zoxide.nu")
atuin init nu --disable-up-arrow | save -f ($path | path join "atuin.nu")
mise activate nu                 | save -f ($path | path join "mise.nu")
