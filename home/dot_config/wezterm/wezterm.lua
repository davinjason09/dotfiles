local config = require("config")
  .init()
  :append("config.appearance")
  :append("config.domains")
  :append("config.general")
  :append("config.keymaps")
  :append("config.launch")

local tabline = require("config.tabline")
tabline.apply_to_config(config)

return config
