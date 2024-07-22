function Select-Apps {
  param (
    [string[]]$apps
  )

  $header = "`n  CTRL+A-Select All   CTRL+D-Deselect All   CTRL+T-Toggle All`n" +
            "`nName" + "`n" + ("─" * 15)

  $apps = $apps | fzf --prompt="Select Apps  " --height=~80% --layout=reverse --cycle `
                      --margin="0,5" --multi --header=$header `
                      --bind="ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all" `

  return $apps
}

function List-ScoopApps {
  $apps = $(scoop list | Select-Object -ExpandProperty "Name").Split("\n")

  return $apps
}

function Update-ScoopApps {
  $appsSet = New-Object System.Collections.Generic.HashSet[[String]]
  $installedApps = List-ScoopApps

  Write-Host -NoNewline "`e[1A`e[0K"
  foreach ($app in Select-Apps $installedApps) {
    if ($app) {
      $app = $app.Split(" ")[0]
      $appsSet.Add($app) > $null
    }
  }

  if ($appsSet.Length) {
    $apps_string = ($appsSet -split ",")
    Write-Host "Selected apps: [$apps_string]"
  } else {
    Write-Host "No app was selected to update"
    return
  }

  $confirm = $(Read-Host "Do you want to update the selected apps? [Y/n] (Default is `"Y`") ").ToUpper()

  if ($confirm -eq "Y" -or $confirm -eq "") {
    scoop update $apps_string
  } else {
    Write-Host "Update was cancelled"
    return
  }
}

function Uninstall-ScoopApps {
  $appsSet = New-Object System.Collections.Generic.HashSet[[String]]
  $installedApps = List-ScoopApps

  Write-Host -NoNewline "`e[1A`e[0K`e[1A`e[0K"
  foreach ($app in Select-Apps $installedApps) {
    if ($app) {
      $app = $app.Split(" ")[0]
      $appsSet.Add($app) > $null
    }
  }

  if ($appsSet.Length) {
    $apps_string = ($appsSet -split ",")
    Write-Host "Selected apps: [$apps_string]"
  } else {
    Write-Host "No app was selected to uninstall"
    return
  }

  $confirm = $(Read-Host "Do you want to uninstall the selected apps? [Y/n] (Default is `"Y`") ").ToUpper()

  if ($confirm -eq "Y" -or $confirm -eq "") {
    scoop uninstall $apps_string
  } else {
    Write-Host "Uninstall was cancelled"
    return
  }
}