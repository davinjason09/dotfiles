return {
  "snacks.nvim",
  opts = {
    dashboard = {
      enabled = true,
      width = 72,
      preset = {
        -- stylua: ignore
        keys = {
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "󱩾 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')", },
          { icon = " ", key = "c", desc = "Config", action = ":lua Utils.picker.chezmoi('nvim')" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        function()
          local is_small_screen = vim.o.lines < 45 or vim.o.columns < 65
          local logo = is_small_screen and "logo-small" or "logo-large"

          return {
            section = "terminal",
            align = "center",
            cmd = "cat " .. vim.fn.stdpath("config") .. "/static/" .. logo .. ".cat; sleep 100ms #",
            indent = is_small_screen and 10 or 6,
            padding = 1,
            height = is_small_screen and 8 or 19,
            width = 62,
          }
        end,
        function()
          local version = ("v%s"):format(Utils.nvim_version())
          local date = os.date("%d.%m.%Y")

          return {
            align = "center",
            text = {
              { " ", hl = "String" },
              { version, hl = "NonText" },
              { "    ", hl = "Delimiter" },
              { date, hl = "NonText" },
            },
          }
        end,
        {
          section = "keys",
          icon = " ",
          title = "Keymaps",
          indent = 2,
          padding = 1,
        },
        function()
          return {
            section = "recent_files",
            cwd = true,
            icon = " ",
            title = "Recent Files",
            indent = 2,
            padding = 1,
            limit = 10,
            enabled = not (vim.o.lines < 45 or vim.o.columns < 65),
          }
        end,
        {
          section = "startup",
          icon = " ",
        },
      },
    },
  },
}
