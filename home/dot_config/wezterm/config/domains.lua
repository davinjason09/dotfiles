---@type Wezterm
local wez = require("wezterm")
local ssh_domains = wez.default_ssh_domains()
local wsl_domains = wez.default_wsl_domains()

for _, item in ipairs(wsl_domains) do
  item.default_prog = { "/usr/bin/nu", "-l" }
end

---@type Config
return {
  ssh_domains = ssh_domains,
  wsl_domains = wsl_domains,
}
