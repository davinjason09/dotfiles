return {
  { "MunifTanjim/nui.nvim" },
  {
    "snacks.nvim",
    opts = {
      lazygit = { configure = false },
      styles = {
        float = { backdrop = 80 },
        notification = {
          zindex = 101,
          wo = { winblend = 0, wrap = true },
        },
        notification_history = {
          width = 0.85,
          wo = {
            signcolumn = "no",
            winhighlight = "Normal:SnacksNormal,FloatBorder:SnacksWinBorder",
          },
        },
        scratch = {
          height = 0.6,
          width = 0.85,
          bo = { buflisted = false, bufhidden = "wipe" },
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
    opts = {
      cmdline = {
        opts = { border = { text = { top_align = "right" } } },
        format = Defaults.noice_cmdline_format,
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
        confirm = {
          -- stylua: ignore
          border = { text = { top = Utils.ui.noice_title({ msg = "  Confirm ", views = "confirm" }) }, },
          win_options = { winhighlight = { FloatTitle = "NoiceConfirmTitle" } },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
      },
    },
    config = function(_, opts)
      if vim.o.filetype == "lazy" then vim.cmd([[messages clear]]) end
      require("noice").setup(opts)
    end,
  },
  {
    "nvim-zh/colorful-winsep.nvim",
    event = { "WinLeave" },
    opts = {
      hi = {
        bg = "#1E1E2E",
        fg = "#89DCE4",
      },
      no_exec_files = {
        "lazy",
        "mason",
        "snacks_dashboard",
        "snacks_notif",
        "snacks_picker_input",
        "snacks_picker_list",
        "snacks_picker_preview",
        "snacks_terminal",
        "snacks_win",
      },
      symbols = { "─", "│", "╭", "╮", "╰", "╯" },
      only_line_seq = false,
    },
  },
}
