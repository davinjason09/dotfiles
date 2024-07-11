Import-Module PSReadLine
Import-Module posh-git
Import-Module CompletionPredictor

# Import-Module "C:\Users\ASUS\Documents\PowerShell\PSFzf-Local\PSFzf-Local.psm1"
Import-Module "$($env:USERPROFILE)\Documents\PowerShell\PsFzf-Local\PSFzf-Local.psm1"

oh-my-posh init pwsh --config "$($env:USERPROFILE)\.config\oh-my-posh\theme.toml" | Invoke-Expression
# zoxide
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

# gh completion
Invoke-Expression -Command $(gh completion -s powershell | Out-String)

# $env:logFile = "$($env:USERPROFILE)\.config\powershell\logs\log.txt"

# Check WIFI Password
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\checkWifiPassword.ps1"

# Compile CPP
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\compileCPP.ps1"

# Clear Cache
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\clearCache.ps1"

# Check Battery
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\checkBattery.ps1"

# Update Apps
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\manageApps.ps1"

# fzf
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\fzf.ps1"

# eza
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\eza.ps1"

# linuxLike Command
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\linuxLike.ps1"

# PSReadline
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\PSReadline.ps1"

# Alias
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\setAlias.ps1"

# Utils
. "$($env:USERPROFILE)\Documents\PowerShell\Scripts\Personal\utils.ps1"

# . C:\Users\ASUS\Documents\PowerShell\gh-copilot.ps1

fastfetch -l "$($env:USERPROFILE)\.config\fastfetch\logo.txt" `
--logo-color-1 "38;2;20;15;14" `
--logo-color-2 "38;2;38;29;26" `
--logo-color-3 "38;2;48;36;32" `
--logo-color-4 "38;2;64;49;44" `
--logo-color-5 "38;2;246;244;241" `
--logo-color-6 "38;2;13;105;9" `
--logo-color-7 "38;2;6;59;5" `
--logo-color-8 "38;2;230;181;144"