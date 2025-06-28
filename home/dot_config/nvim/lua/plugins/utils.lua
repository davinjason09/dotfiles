return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end, desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session", },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session", },
    },
  },
  {
    "snacks.nvim",
    opts = {
      indent = {
        enabled = true,
        scope = { enabled = false },
        chunk = {
          enabled = true,
          priority = 20,
          char = {
            corner_top = "╭",
            corner_bottom = "╰",
            arrow = "",
          },
        },
        animate = { easing = "inOutSine" },
        filter = function(buf)
          local filetype = vim.bo[buf].filetype

          return vim.g.snacks_indent ~= false
            and vim.b[buf].snacks_indent ~= false
            and vim.bo[buf].buftype == ""
            and not vim.tbl_contains(Defaults.excluded_filetypes, filetype)
        end,
      },
      input = {
        win = {
          relative = "cursor",
          row = 1,
          keys = {
            i_esc = { "<ESC>", { "cmp_close", "cancel" }, mode = "i" },
            i_ctrl_bs = { "<C-BS>", "<C-S-W>", mode = { "i" }, expr = true },
            i_ctrl_s = { "<C-S>", { "confirm" }, mode = { "i" }, expr = true },
          },
        },
      },
      notifier = { enabled = true, style = "fancy" },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = "VeryLazy",
    version = "*",
    opts = {
      highlight = {
        style = "virtual_left",
        virtual_text = Defaults.icons.kind.Color,
        ignore_ft = { "blink-cmp-menu", "noice" },
      },
      patterns = {
        hex = { priority = -1, "%f[^\"':%s>]()#%x%x%x+%f[%W%p%s%c%z]()" },
        hex_literal = { priority = -1, "()0x%x%x%x%x%x%x+%f[%W%p%s%c%z]()" },
        css_rgb = { priority = -1, "()rgba?%(.-%)()" },
        css_hsl = { priority = -1, "()hsla?%(.-%)()" },
        css_oklch = { priority = -1, "()oklch%([^,]-%)()" },
        tailwind = { priority = -2, "%f[%w][%l%-]-%-()%l-%-%d%d%d?%f[%W]()" },
        numbers_in_brackets = false,
      },
    },
  },
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    opts = {
      type_icons = {
        E = " ",
        W = " ",
        I = " ",
        N = " ",
        H = " ",
      },
      borders = {
        vert = "│",
        strong_header = "─",
        strong_cross = "┼",
        strong_end = "┤",
        soft_header = "╌",
        soft_cross = "┼",
        soft_end = "┤",
      },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_enable = true,
      auto_resize_height = true,
      preview = {
        delay_syntax = 25,
        winblend = 1,
      },
    },
  },
}
