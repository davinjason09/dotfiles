function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Reload-Profile {
  . $PROFILE
}

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
  $dir = Get-Location
  $destination = Join-Path -Path $dir -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($file))
  Write-Output("Extracting $file to $destination...")
  Expand-Archive -Path $file -DestinationPath $destination
}