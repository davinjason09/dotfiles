$ScriptBlock = {
  Param([string]$line)
  if ($line -like " *") {
    return $false
  } 

  $ignorePSReadline = @("user", "pass", "account")
  foreach ($ignore in $ignorePSReadline) {
    if ($line -match $ignore) {
      return $false
    }
  }

  return $true
}

$PSReadLineOptions = @{
  ExtraPromptLineCount = $true
  HistoryNoDuplicates = $true
  MaximumHistoryCount = 5000
  PredictionSource = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
  ShowToolTips = $true
}

Set-PSReadLineOption @PSReadLineOptions
Set-PSReadLineOption -Colors @{ InlinePrediction = "#86b567"}

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward