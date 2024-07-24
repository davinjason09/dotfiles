oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\theme.toml" | Invoke-Expression
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

# Import-Module PSReadLine
Import-Module '~\Documents\PowerShell\PsFzf-Local'
Import-Module CompletionPredictor
# Import-Module posh-wakatime
Import-Module Catppuccin

$Flavor = $Catppuccin['Mocha']

fastfetch

function fortune {
  [System.IO.File]::ReadAllText((Split-Path $profile)+'\fortune.txt') -replace "`r`n", "`n" -split "`n%`n" | Get-Random
}

$env:fzfLog = '~\Documents\PowerShell\Logs\PSFzf.log'
$env:errorLog = '~\Documents\PowerShell\Logs\Error.log'
$env:KOMOREBI_CONFIG_HOME = "$env:USERPROFILE\.config\komorebi"

. "~\Documents\PowerShell\Scripts\Personal\PSReadline.ps1"
. "~\Documents\PowerShell\Scripts\Personal\fzf.ps1"
. "~\Documents\PowerShell\Scripts\Personal\eza.ps1"
. "~\Documents\PowerShell\Scripts\Personal\checkWifiPassword.ps1"
. "~\Documents\PowerShell\Scripts\Personal\compileCPP.ps1"
. "~\Documents\PowerShell\Scripts\Personal\clearCache.ps1"
. "~\Documents\PowerShell\Scripts\Personal\checkBattery.ps1"
. "~\Documents\PowerShell\Scripts\Personal\komorebi.ps1"
. "~\Documents\PowerShell\Scripts\Personal\manageApps.ps1"
. "~\Documents\PowerShell\Scripts\Personal\linuxLike.ps1"
. "~\Documents\PowerShell\Scripts\Personal\setAlias.ps1"
. "~\Documents\PowerShell\Scripts\Personal\utils.ps1"

$PSStyle.Formatting.Debug = $Flavor.Sky.Foreground()
$PSStyle.Formatting.Error = $Flavor.Red.Foreground()
$PSStyle.Formatting.ErrorAccent = $Flavor.Blue.Foreground()
$PSStyle.Formatting.FormatAccent = $Flavor.Teal.Foreground()
$PSStyle.Formatting.TableHeader = $Flavor.Rosewater.Foreground()
$PSStyle.Formatting.Verbose = $Flavor.Yellow.Foreground()
$PSStyle.Formatting.Warning = $Flavor.Peach.Foreground()