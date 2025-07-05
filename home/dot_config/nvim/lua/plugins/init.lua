require("config").init()

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
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
      layout.default.layout.zindex = 100
      layout.default.layout[2].width = 0.65
      layout.default.layout.backdrop = {
        blend = 80,
        win = { relative = "editor", zindex = 99 },
      }

      layout.dropdown.layout.min_width = 100
      layout.dropdown.layout.zindex = 100
      layout.dropdown.layout.width = 0.65

      layout.ivy.layout.zindex = 100
      layout.ivy_split.layout.zindex = 100
      layout.select.layout.zindex = 100
      layout.sidebar.layout.zindex = 100
      layout.telescope.layout.zindex = 100
      layout.vertical.layout.zindex = 100

      -- NOTE: Override Snacks.util.icon with our own implementation
      Snacks.util.icon = function(name, cat, _)
        return Utils.get_icon({ fs_type = cat or "file", path = name })
      end
    end,
    -- stylua: ignore
    keys = {
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "[D]ebug: [P]rofiler [S]cratch Buffer" },
      { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          -- stylua: ignore start
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }) :map("<leader>uc")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.dim():map("<leader>uD")
          Snacks.toggle.animate():map("<leader>ua")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.scroll():map("<leader>uS")
          Snacks.toggle.profiler():map("<leader>dpp")
          Snacks.toggle.profiler_highlights():map("<leader>dph")
          Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
          Snacks.toggle.zen():map("<leader>uz")
          -- stylua: ignore end
        end,
      })
    end,
  },
}
