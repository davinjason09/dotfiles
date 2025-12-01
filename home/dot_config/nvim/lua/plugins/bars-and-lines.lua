return {
  "rebelot/heirline.nvim",
  event = { "VeryLazy", "BufReadPre", "BufNewFile" },
  lazy = vim.fn.argc(-1) == 0,
  config = function()
    local Config = require("custom.lines")
    local colors = require("catppuccin.palettes").get_palette("mocha")

    require("heirline").setup({
      statusline = Config.Statusline,
      tabline = Config.Tabline,
      opts = { colors = colors },
    })

    -- TODO: override utils.page_buflist to make the behavior more like bufferline.nvim
    Config.setup()
  end,
}
