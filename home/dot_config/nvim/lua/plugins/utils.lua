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
      ---@type snacks.notifier.Config
      notifier = {
        enabled = true,
        margin = { right = 0 },
        ---@type snacks.notifier.render
        style = function(buf, notif, ctx)
          local width = math.max(40, vim.o.columns * 0.4)
          local time = os.date(ctx.notifier.opts.date_format, notif.added)
          local gap = width - #time - #(notif.title or "") - (#notif.icon or "")
          local title = (" %s%s%s%s"):format(
            notif.icon or "",
            vim.trim(notif.title or ""),
            string.rep(" ", gap),
            time
          )

          if title ~= "" then ctx.opts.title = title end
          ctx.opts.border = { "▍", " ", "🮈", "🮈", "🮈", " ", "▍", "▍" }

          -- stylua: ignore start
          vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "", "" })
          vim.api.nvim_buf_set_lines(buf, 1, -1, false, vim.split(notif.msg, "\n"))
          vim.api.nvim_buf_set_extmark(buf, ctx.ns, 0, 0, {
            virt_text = { { string.rep("🭸", width - 2), ctx.hl.border }, { " " } },
            virt_text_win_col = 0,
            priority = 10,
          })
          -- stylua: ignore end
        end,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      terminal = { enabled = true },
      words = { enabled = true },
    },
  },
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = { "BufReadPost", "BufNewFile" },
    version = "*",
    opts = {
      highlight = {
        style = "virtual_left",
        virtual_text = Defaults.icons.kind.Color,
        ignore_ft = { "blink-cmp-menu", "noice", "lazy" },
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
      type_icons = { E = " ", W = " ", I = " ", N = " ", H = " " },
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
