Set-Alias -Name c -Value code
Set-Alias -Name g git

Set-Alias -Name cc -Value Compile_Run_Cc -Option AllScope

if (Get-Command lazygit) {
  Set-Alias lg lazygit
}

if (Get-Command sl.exe) {
  Set-Alias -Name sl -Value sl.exe -Force
}
