$env:FZF_DEFAULT_OPTS = @"
--color=fg:#E4F0FB,fg+:#FFFFFF,bg:-1,bg+:#262626
--color=hl:#91B4D5,hl+:#88DDFF,info:#FFDC96,marker:#AAE682
--color=prompt:#CF679D,spinner:#5DE4C7,pointer:#9696FF,header:#5FB3A0
--color=gutter:#121212,border:#42675A,scrollbar:#5DE4C7,preview-scrollbar:#5DE4C7
--color=label:#aeaeae,query:#FFFFFF --layout=reverse
--cycle --height=50% --border="rounded"
--prompt=" " --marker="" --pointer="󰜴"
--separator="─" --scrollbar="│"             
--bind alt-w:toggle-preview-wrap
--bind ctrl-e:toggle-preview
"@

$env:_PSFZF_FZF_DEFAULT_OPTS = $env:FZF_DEFAULT_OPTS

$env:FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git --fixed-strings --strip-cwd-prefix --color always"
$env:FZF_ALT_C_OPTS = @"
--prompt='Directory  ' 
--preview="eza --tree --level=1 --color=always --icons=always {}" 
--preview-window=right:50%:border-left
"@

$commandOverride = [ScriptBlock]{ param($Location) cd $Location }

Set-PsFzfOption -AltCCommand $commandOverride

Set-PSReadlineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -PSReadlineChordProvider "Ctrl+t" -PSReadlineChordReverseHistory "Ctrl+r"  -PSReadlineChordReverseHistoryArgs "Alt+a"
Set-PsFzfOption -GitKeyBindings -EnableAliasFuzzyGitStatus -EnableAliasFuzzyEdit -EnableAliasFuzzyKillProcess -EnableAliasFuzzyScoop -EnableFd
Set-PsFzfOption -TabExpansion