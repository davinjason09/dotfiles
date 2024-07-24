$env:FZF_DEFAULT_OPTS = @"
--color=fg:#cad3f5,fg+:#d0d0d0,bg:-1,bg+:#262626
--color=hl:#ed8796,hl+:#5fd7ff,info:#c6a0f6,marker:#AAE682
--color=prompt:#c6a0f6,spinner:#f4dbd6,pointer:#f4dbd6,header:#ed8796
--color=border:#585b70,label:#aeaeae,query:#d9d9d9 
--layout=reverse --cycle --height=~80% --border="rounded"
--prompt=" " --marker="" --pointer="󰜴" --padding=1
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