---@diagnostic disable: undefined-field
local config = require("config")
  :init()
  :append(require("config.appearance"))
  :append(require("config.domains"))
  :append(require("config.general"))
  :append(require("config.keymaps"))

return config
