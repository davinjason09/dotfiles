return {
  condition = require("lazy.status").has_updates,
  update = { "User", pattern = "LazyUpdate" },
  on_click = {
    callback = function()
      vim.defer_fn(function() vim.cmd("Lazy") end, 100)
    end,
    name = "update_plugins",
  },
  provider = function() return (" %s "):format(require("lazy.status").updates()) end,
  hl = { fg = "pink" },
}
