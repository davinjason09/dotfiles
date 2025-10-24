return {
  default_prog = { "C:/WINDOWS/system32/wsl.exe" },
  default_domain = "WSL:Arch",
  launch_menu = {
    {
      label = "MSYS2",
      args = { "C:/msys64/msys2_shell.cmd", "-defterm", "-here", "-no-start", "-ucrt64" },
      domain = { DomainName = "local" },
    },
    {
      label = "Powershell",
      args = { "pwsh.exe", "-NoLogo" },
      domain = { DomainName = "local" },
    },
    {
      label = "Windows Powershell",
      args = { "powershell.exe", "-NoLogo" },
      domain = { DomainName = "local" },
    },
    {
      label = "CMD",
      args = { "cmd.exe" },
      domain = { DomainName = "local" },
    },
  },
}
