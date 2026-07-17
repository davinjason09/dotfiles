---@type Config
return {
  default_prog = { "C:/WINDOWS/system32/wsl.exe" },
  default_domain = "WSL:Arch",
  launch_menu = {
    {
      label = "Nushell Windows",
      args = { "nu.exe" },
      domain = { DomainName = "local" },
    },
    {
      label = "Powershell",
      args = { "pwsh.exe", "-NoLogo" },
      domain = { DomainName = "local" },
    },
    {
      label = "CMD",
      args = { "cmd.exe" },
      domain = { DomainName = "local" },
    },
  },
}
