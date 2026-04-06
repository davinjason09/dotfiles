return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      history = true,
      update_events = { "InsertLeave", "TextChanged", "TextChangedI" },
      delete_check_events = "TextChanged",
    },
    config = function(_, opts)
      require("luasnip").setup(opts)

      local loaders = require("luasnip.loaders.from_vscode")
      loaders.lazy_load()
      loaders.lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
    end,
  },
}
