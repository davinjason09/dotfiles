# Ref = https://github.com/KevinNitroG/windows-dotfiles/blob/main/Documents/PowerShell/Scripts/kevinnitro/checkWifiPassword.ps1
function Check-WiFiPassword {
  param (
    [string]$name = $null
  )

  if (-not $name) {
		if (Get-Command fzf -ErrorAction SilentlyContinue) {
			$name = netsh wlan show profiles 
				| Select-String -Pattern "All User Profile\s+:\s+(.*)"
				| ForEach-Object { $_.Matches.Groups[1].Value } 
				| fzf --prompt="Select Wi-Fi  " --height=~80% --layout=reverse --border=rounded --exit-0 --cycle --margin="2,40" --padding=1
    } else {
			"LIST OF SAVED WI-FI"
			"`n---`n"
			$wifiList = netsh wlan show profiles |
				Select-String -Pattern "All User Profile\s+:\s+(.*)" |
				ForEach-Object { $_.Matches.Groups[1].Value }
			
			for ($i = 0; $i -lt $wifiList.Length; $i++) {
				"{0,5}: {1}" -f ($i+1), $wifiList[$i]
			}

			"`n---`n"

			$inputPosition = Read-Host "Enter the number of the Wi-Fi network you want to check the password (Enter for current network)"

			if ([String]::IsNullOrEmpty($inputPosition)) {
				$name = ((netsh wlan show interfaces | Select-String -Pattern "Profile" -Context 0,1) -split ":")[1].Trim()
			} else {
				$index = [int]$inputPosition - 1
				if ($index -ge 0 -and $index -lt $wifiList.Count) {
					$name = $wifiList[$index]
				} else {
					"Invalid input. Please try again."
					return
				}
			}
		}
  }

	if (-not $name) {
		"No Wi-Fi network selected."
		return
	}

	$wlanProfile = netsh wlan show profile name="$name" key=clear
	$password = $wlanProfile | Select-String -Pattern "Key Content\s+:\s+(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
	Write-Host "Wi-Fi network: $name"

	if ($password) {
		Write-Host "Password: $password"
	} else {
		Write-Host "No password found."
	}
}
	if ($password) {
		Write-Host "Password: $password"
	} else {
		Write-Host "No password found."
	}
}