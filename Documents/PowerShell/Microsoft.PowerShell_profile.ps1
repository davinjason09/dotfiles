if (-not $Global:PSDefaultParameterValues) { $Global:PSDefaultParameterValues = @{} }

$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$Global:PSDefaultParameterValues['*:Encoding'] = $Global:PSDefaultParameterValues['*:InputEncoding'] = $Global:PSDefaultParameterValues['*:OutputEncoding'] = $OutputEncoding

oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\theme.toml" | Invoke-Expression
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

Import-Module PSReadLine
Import-Module '~\Documents\PowerShell\PsFzf-Local'
Import-Module CompletionPredictor
Import-Module posh-git
# Import-Module PSFzf

# if (Get-Command starship -ErrorAction SilentlyContinue) {
  #   $env:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship\starship.toml"
  #   starship init powershell --print-full-init | Out-String | Invoke-Expression
  # }
  
$env:fzfLog = '~\Documents\PowerShell\Logs\PSFzf.log'
$env:errorLog = '~\Documents\PowerShell\Logs\Error.log'
$env:PWSH_DEFERRED_LOAD = 1
$LogDeferredLoad = $false

$DeferredLoad = {
  "dot sourcing script" | Write-DeferredLoadLog

  # PSReadline
  . "~\Documents\PowerShell\Scripts\Personal\PSReadline.ps1"
  
  # fzf
  . "~\Documents\PowerShell\Scripts\Personal\fzf.ps1"
  
  # eza
  . "~\Documents\PowerShell\Scripts\Personal\eza.ps1"
  
  # Check WIFI Password
  . "~\Documents\PowerShell\Scripts\Personal\checkWifiPassword.ps1"
  
  # Compile CPP
  . "~\Documents\PowerShell\Scripts\Personal\compileCPP.ps1"
  
  # Clear Cache
  . "~\Documents\PowerShell\Scripts\Personal\clearCache.ps1"
  
  # Check Battery
  . "~\Documents\PowerShell\Scripts\Personal\checkBattery.ps1"
  
  # Update Apps
  . "~\Documents\PowerShell\Scripts\Personal\manageApps.ps1"
  
  # linuxLike Command
  . "~\Documents\PowerShell\Scripts\Personal\linuxLike.ps1"
  
  # Alias
  . "~\Documents\PowerShell\Scripts\Personal\setAlias.ps1"
  
  # Utils
  . "~\Documents\PowerShell\Scripts\Personal\utils.ps1"

  "completed dot-sourcing script" | Write-DeferredLoadLog
}

function Write-DeferredLoadLog {
  param (
    [Parameter(Mandatory, ValueFromPipeline)]
    [String]$Message
  )

  if (-not $LogDeferredLoad) { return }

  $LogPath = '~\Documents\PowerShell\Logs\DeferredLoad.log'

  $Now = [DateTime]::Now
  if (-not $Start) {
    $Global:Start = $Now
  }

  $Timestamp = $Now.ToString('o')
  (
    $Timestamp,
    ($Now - $Start).ToString('ss\.fff'),
    [System.Environment]::CurrentManagedThreadId.ToString().PadLeft(3, ' '),
    $Message
  ) -join '  ' | Out-File -FilePath $LogPath -Append
}

if ($env:PWSH_DEFERRED_LOAD -imatch '^(0|false|no)$') {
  . $DeferredLoad
  return
}

"=== Starting deferred load ===" | Write-DeferredLoadLog
$LogDeferredLoad = $false

$GlobalState = [PSModuleInfo]::new($false)
$GlobalState.SessionState = $ExecutionContext.SessionState

$Runspace = [RunspaceFactory]::CreateRunspace($Host)
$Powershell = [PowerShell]::Create($Runspace)
$Runspace.Open()
$Runspace.SessionStateProxy.SetVariable('GlobalState', $GlobalState)

$Private = [Reflection.BindingFlags]'Instance, NonPublic'
$ContextField = [Management.Automation.EngineIntrinsics].GetField('_context', $Private)
$Context = $ContextField.GetValue($ExecutionContext)

$ContextCACProperty = $Context.GetType().GetProperty('CustomArgumentCompleters', $Private)
$ContextNACProperty = $Context.GetType().GetProperty('NativeArgumentCompleters', $Private)
$CAC = $ContextCACProperty.GetValue($Context)
$NAC = $ContextNACProperty.GetValue($Context)

if ($null -eq $CAC) {
    $CAC = [Collections.Generic.Dictionary[String, ScriptBlock]]::new()
    $ContextCACProperty.SetValue($Context, $CAC)
}

if ($null -eq $NAC) {
    $NAC = [Collections.Generic.Dictionary[String, ScriptBlock]]::new()
    $ContextNACProperty.SetValue($Context, $NAC)
}

$RSEngineField = $Runspace.GetType().GetField('_engine', $Private)
$RSEngine = $RSEngineField.GetValue($Runspace)
$EngineContextField = $RSEngine.GetType().GetFields($Private) | Where-Object {$_.FieldType.Name -eq 'ExecutionContext'}
$RSContext = $EngineContextField.GetValue($RSEngine)

$ContextCACProperty.SetValue($RSContext, $CAC)
$ContextNACProperty.SetValue($RSContext, $NAC)

Remove-Variable -ErrorAction Ignore (
  'Private',
  'GlobalContext',
  'ContextField',
  'ContextCACProperty',
  'ContextNACProperty',
  'CAC',
  'NAC',
  'RSEngineField',
  'RSEngine',
  'EngineContextField',
  'RSContext',
  'Runspace'
)

$Wrapper = {
  Start-Sleep -Milliseconds 100

  . $GlobalState {. $DeferredLoad; Remove-Variable DeferredLoad}
}

$AsyncResult = $Powershell.AddScript($Wrapper.ToString()).BeginInvoke()

$logError = $true
$null = Register-ObjectEvent -MessageData $AsyncResult -InputObject $Powershell -EventName InvocationStateChanged -SourceIdentifier __DeferredLoaderCleanup -Action {
  $AsyncResult = $Event.MessageData
  $Powershell = $Event.Sender

  if ($Powershell.InvocationStateInfo.State -ge 2) {
    if ($Powershell.Streams.Error) {
      $Powershell.Streams.Error | Out-String | Write-Host -ForegroundColor Red
    if ($Powershell.Streams.Error -and $logError) {
      $Powershell.Streams.Error | Out-String | Out-File -FilePath $env:errorLog -Append
    }

    try {
      $null = $Powershell.EndInvoke($AsyncResult)
    } catch {
      $_ | Out-String | Out-File -FilePath $env:errorLog -Append
    }

    $PowerShell.Dispose()
    $Runspace.Dispose()
    Unregister-Event __DeferredLoaderCleanup
    Get-Job __DeferredLoaderCleanup | Remove-Job
  }
}

Remove-Variable Wrapper, Powershell, AsyncResult, GlobalState

"Synchronous load complete" | Write-DeferredLoadLog

fastfetch 