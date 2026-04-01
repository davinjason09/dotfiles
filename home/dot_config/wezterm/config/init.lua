local M = {}

local wez = require("wezterm") ---@type Wezterm

function M.init() return setmetatable(wez.config_builder(), { __index = M }) end

---@param opts string|table
function M:append(opts)
  if type(opts) == "string" then opts = require(opts) end

  ---@cast opts table
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
