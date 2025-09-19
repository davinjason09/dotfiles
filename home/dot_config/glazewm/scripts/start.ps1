function Has-Started {
  param (
    [string]$name
  )
  $started = Get-Process | Where-Object { $_.Name -eq $name }

  return $started -ne $null
}

Start-ScheduledTask -TaskName "Tacky-Borders"
start $HOME/.glzr/scripts/disablewintoopenmenu.ahk
start Everything --startup

if (-not (Has-Started "Flow.Launcher")) {
  start FlowLauncher
}

if (-not (Has-Started "kanata-tray")) {
  start kanata-tray
}
