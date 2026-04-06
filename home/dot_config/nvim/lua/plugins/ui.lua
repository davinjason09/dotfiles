return {
  { "MunifTanjim/nui.nvim" },
  {
    "snacks.nvim",
    opts = {
      lazygit = { configure = false },
      styles = {
        float = { backdrop = 80 },
        notification = {
          wo = { winblend = 0, wrap = true },
        },
        notification_history = {
          width = 0.85,
          wo = {
            signcolumn = "no",
            winhighlight = "Normal:SnacksNormal,FloatBorder:SnacksWinBorder",
          },
        },
        ---@type snacks.scratch.Config
        scratch = {
          height = 0.8,
          width = 0.8,
          wo = {
            winhighlight = "Normal:SnacksNormal,FloatBorder:SnacksWinBorder",
          },
        },
      },
      win = {
        wo = {
          winhighlight = "Normal:SnacksNormal,NormalNC:SnacksNormalNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC,FloatBorder:SnacksWinBorder",
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = function()
      local cmdline_format = Defaults.noice_cmdline_format()

      return {
        cmdline = {
          opts = { border = { text = { top_align = "right" } } },
          format = cmdline_format,
        },
        lsp = {
          documentation = { enabled = false },
          progress = { enabled = false },
          signature = { enabled = false },
          hover = { enabled = false },
        },
        popupmenu = { enabled = false },
        routes = {
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
                { find = "%(mini%.*" },
                { find = "No lines in buffer" },
                { find = "^%d+ fewer lines;?" },
                { find = "^%d+ more lines?;?" },
                { find = "^%d+ line less;?" },
                { find = "^Already at newest change" },
              },
            },
            view = "mini",
          },
          {
            filter = {
              event = "notify",
              cond = function(msg) return msg.opts and (msg.opts.title or ""):find("tinymist") end,
            },
            view = "mini",
          },
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "Agent service not initialized" },
                { find = "Request getCompletions failed with" },
              },
            },
            opts = { skip = true },
          },
        },
        views = {
          cmdline = {
            position = { row = -1, col = 0 },
            zindex = 200,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
        },
      }
    end,
    config = function(_, opts)
      if vim.o.filetype == "lazy" then vim.cmd([[messages clear]]) end
      require("noice").setup(opts)
    end,
  },
}
