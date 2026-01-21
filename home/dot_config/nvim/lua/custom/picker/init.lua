local M = {}

M.sources = {
  chezmoi = require("custom.picker.chezmoi").source,
  options = require("custom.picker.options").source,
  reload = require("custom.picker.reload").source,
}

M._did_setup = false
M.setup = function()
  if M._did_setup then return true end
  M._did_setup = true

  if not (Snacks and Snacks.picker) then return end

  for name, config in pairs(M.sources) do
    Snacks.picker.sources[name] = config
  end
end

return M
