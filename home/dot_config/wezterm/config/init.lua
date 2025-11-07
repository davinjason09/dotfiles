local M = {}
M.__index = M

local wez = require("wezterm") ---@type Wezterm

---@return Config
function M.init()
  local self = setmetatable(wez.config_builder(), M)
  return self
end

---@param opts table
---@return Config
function M:append(opts)
  for k, v in pairs(opts) do
    if self[k] ~= nil then
      wez.log_warn("Duplicate config option detected!", { old = self[k], new = opts[k] })
    else
      self[k] = v
    end
  end

  return self
end

return M
