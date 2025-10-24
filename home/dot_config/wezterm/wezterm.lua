---@diagnostic disable: undefined-field
local config = require("config")
  :init()
  :append(require("config.appearance"))

return config
