Set-Alias -Name c -Value code
Set-Alias -Name g git

if (Get-Command lazygit) {
  Set-Alias lg lazygit
}

Set-Alias -Name cc -Value Compile_Run_Cc -Option AllScope