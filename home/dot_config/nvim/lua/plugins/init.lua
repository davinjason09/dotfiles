require("config").init()

return {
  "folke/snacks.nvim",
  priority = 10000,
  lazy = false,
  config = function(_, opts)
    local notify = vim.notify
    require("snacks").setup(opts)

    -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
    -- this is needed to have early notifications show up in noice history
    if Utils.has("noice.nvim") then vim.notify = notify end

    -- Customize default picker layout
    local layout = require("snacks.picker.config.layouts")
    layout.default.layout.min_width = 100
    layout.default.layout[2].width = 0.65

    layout.dropdown.layout.min_width = 100
    layout.dropdown.layout.width = 0.65

    layout.vertical.layout.width = 0.8
    layout.vertical.layout.height = 0.65
    layout.vertical.layout[2].height = 0.4

    -- Setup custom pickers
    require("custom.picker").setup()

    -- NOTE: Override Snacks.util.icon with our own implementation

    ---@param name IconType
    ---@param cat? string
    ---@param icon_opts? { fallback: { dir: string, file: string }? }
    Snacks.util.icon = function(name, cat, icon_opts)
      icon_opts = icon_opts or { fallback = { dir = " ", file = " " } }
      local icon, hl, default = Utils.get_icon({ fs_type = cat or "file", path = name })
      if default then icon = icon_opts.fallback[cat or "file"] end
      return icon, hl
    end
  end,
  -- stylua: ignore
  keys = {
    { "<leader>.",   function() Snacks.scratch() end,              desc = "Toggle Scratch Buffer" },
    { "<leader>S",   function() Snacks.scratch.select() end,       desc = "Select Scratch Buffer" },
    { "<leader>dps", function() Snacks.profiler.scratch() end,     desc = "[D]ebug: [P]rofiler [S]cratch Buffer" },
    { "<leader>n",   function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>un",  function() Snacks.notifier.hide() end,        desc = "Dismiss All Notifications" },
    { "<leader>gB",  function() Snacks.gitbrowse() end,            desc = "Git Browse", mode = { "n", "v" } },
  },
  init = function()
    Utils.on_very_lazy(function()
      _G.dd = function(...) Snacks.debug.inspect(...) end
      _G.bt = function() Snacks.debug.backtrace() end
      vim._print = function(_, ...) dd(...) end

      -- Create some toggle mappings
      -- stylua: ignore start
      Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
      Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
      Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }) :map("<leader>uc")
      Snacks.toggle.diagnostics():map("<leader>ud")
      Snacks.toggle.line_number():map("<leader>ul")
      Snacks.toggle.treesitter():map("<leader>uT")
      Snacks.toggle.dim():map("<leader>uD")
      Snacks.toggle.indent():map("<leader>ug")
      Snacks.toggle.profiler():map("<leader>dpp")
      Snacks.toggle.profiler_highlights():map("<leader>dph")
      Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
      Snacks.toggle.zen():map("<leader>uz")
      Utils.format.snacks_toggle():map("<leader>uf")
      Utils.format.snacks_toggle(true):map("<leader>uF")
      -- stylua: ignore end
    end)
  end,
}
