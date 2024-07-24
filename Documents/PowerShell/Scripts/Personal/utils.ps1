$canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Reload-Profile {
  . $PROFILE
}

Set-Alias -Name rl -Value Reload-Profile

function Get-PubIp {
  (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

function _Get-Uptime {
  $bootupTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
  $currentDate = Get-Date
  $uptime = $currentDate - $bootupTime
  Write-Output "Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes, $($uptime.Seconds) seconds"
}

function uptime {
  If ($PSVersionTable.PSVersion.Major -eq 5 ) {
    Get-WmiObject win32_operatingsystem |
      Select-Object @{EXPRESSION={ $_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
  } Else {
    _Get-Uptime
    net statistics workstation | Select-String "since" | foreach-object {$_.ToString().Replace('Statistics since ', 'Since: ')}
  }
}

function unzip ($file) {
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function export($name, $value) {
  Set-Item -Path "env:$name" -Value $value
}

function df {
  Get-Volume
}

function sysinfo {
  Get-ComputerInfo
}

function Update-Powershell {
  if (-not $Global:canConnectToGithub) {
    Write-Host "Cannot connect to GitHub. Please check your internet connection." -ForegroundColor Yellow
    return
  }

  try {
    Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
    $updateNeeded = $false
    $currentVersion = $PSVersionTable.PSVersion.ToString()
    $githubAPIurl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
    $latestRelease = Invoke-RestMethod -Uri $githubAPIurl
    $latestVersion = $latestRelease.tag_name.Trim('v')

    if ($currentVersion -lt $latestVersion) {
      $updateNeeded = $true
    }

    if ($updateNeeded) {
      Write-Host "Updating PowerShell..." -ForegroundColor Yellow
      winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
      Write-Host "PowerShell has been updated. Please restart your terminal" -ForegroundColor Magenta
    } else {
      Write-Host "PowerShell is up to date." -ForegroundColor Green
    }
  } catch {
    Write-Host "Failed to Update Powershell. Error = $_" -ForegroundColor Red
  }
}