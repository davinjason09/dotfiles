$global:lastRepository = ""

function Check-DirectoryForNewRepository {
  $currentRepository = & git rev-parse --show-toplevel 2> $null
    
  if ($currentRepository -and ($currentRepository -ne $global:lastRepository)) {
    onefetch
  }
  
  $global:lastRepository = $currentRepository
}

function cd-onefetch {
  param (
    [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true, Position=0)]
    [Alias("Path")]
    [String[]]$Location
  )

  if ($Location -eq $null) {
    $path = "~"
  } else {
    $path = $Location | ForEach-Object { $_.ToString() }
  }

  if (Get-Command zoxide.exe -ErrorAction SilentlyContinue) {
    __zoxide_z @path
  } else {
    Set-Location $path
  }

  Check-DirectoryForNewRepository
}

Set-Alias -Name cd -Value cd-onefetch -Option AllScope