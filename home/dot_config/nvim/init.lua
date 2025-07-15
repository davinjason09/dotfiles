if vim.loader then vim.loader.enable() end

_G.Utils = require("utils")
_G.Defaults = require("config.defaults")

require("config").setup()
