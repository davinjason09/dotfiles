local config = require("config")
  .init()
  :append(require("config.appearance"))
  :append(require("config.domains"))
  :append(require("config.general"))
  :append(require("config.keymaps"))
  :append(require("config.launch"))

local tabline = require("config.tabline")
tabline.apply_to_config(config)

return config
