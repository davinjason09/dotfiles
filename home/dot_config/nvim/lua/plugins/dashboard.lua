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
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        function()
          local height = vim.o.lines
          local is_small_screen = height <= 30
          local logo = is_small_screen and "logo-small" or "logo-large"

          return {
            section = "terminal",
            align = "center",
            cmd = "cat " .. vim.fn.stdpath("config") .. "/static/" .. logo .. ".cat",
            indent = is_small_screen and 10 or 6,
            padding = 1,
            height = is_small_screen and 8 or 19,
            width = 62,
          }
        end,
        function()
          local version = vim.version()
          version = ("v%d.%d.%d"):format(version.major, version.minor, version.patch)
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
        {
          section = "recent_files",
          icon = " ",
          title = "Recent Files",
          indent = 2,
          padding = 1,
          limit = 10,
          enabled = vim.o.lines > 30,
        },
        {
          section = "startup",
          icon = " ",
        },
      },
    },
  },
}
