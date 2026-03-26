return {
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "astro",
      "html",
      "javascript",
      "javascriptreact",
      "jsx",
      "markdown",
      "tsx",
      "typescript",
      "typescriptreact",
      "xml",
    },
    opts = {},
  },
  {
    "saghen/blink.pairs",
    event = { "InsertEnter", "BufReadPre", "BufNewFile" },
    build = "cargo build --release",
    ---@type blink.pairs.Config
    opts = {
      mappings = {
        enabled = true,
        cmdline = false,
        wrap = {
          ["<C-b>"] = "motion",
          ["<C-S-b>"] = "motion_reverse",
          ["<C-l>"] = "treesitter",
          ["<C-h>"] = "treesitter_reverse",
        },
        pairs = {
          ['"'] = {
            {
              '"',
              enter = false,
              space = false,
              when = function(ctx) return ctx:text_before_cursor(2) ~= '\\"' end,
            },
          },
        },
      },
      highlights = {
        enabled = true,
        cmdline = false,
        groups = { "BlinkPairsYellow", "BlinkPairsPurple", "BlinkPairsBlue" },
        unmatched_group = "BlinkPairsUnmatched",
        matchparen = { enabled = true },
      },
      debug = false,
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      triggers = {
        { "<auto>", mode = "nxso" },
        { "s", mode = "nx" },
      },
      win = {
        width = { min = 10, max = 40 },
        height = { min = 4, max = 0.75 },
        padding = { 0, 1 },
        col = -1,
        row = -1,
        border = "rounded",
        title = true,
        title_pos = "left",
      },
      layout = {
        width = { min = 10, max = 40 },
      },
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = false },
      },
      icons = Defaults.which_key_rules,
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>E", group = "explorer" },
          { "<leader>f", group = "find/file" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>sn", group = "noice" },
          { "<leader>u", group = "ui" },
          { "<leader>x", group = "diagnostics/quickfix" },
          {
            "<leader>b",
            group = "buffer",
            expand = function() return require("which-key.extras").expand.buf() end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<C-w>",
            expand = function() return require("which-key.extras").expand.win() end,
          },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gc", group = "comment" },
          { "gx", desc = "Open with system app", icon = { icon = " ", color = "red" } },
          { "g%", desc = "Matching (){}[]" },
          { "s", group = "surround" },
          { "z", group = "fold" },
        },
        { "sn", desc = "Update `n` lines" },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps (which-key)", },
      { "<C-w><Space>", function() require("which-key").show({ keys = "<C-w>", loop = true }) end, desc = "Window Hydra Mode (which-key)", },
    },
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {},
    -- stylua: ignore
    keys = {
      ---@diagnostic disable: undefined-field
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "[S]earch [T]ODO", },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "[S]earch [T]ODO/FIX/FIXME", },
      { "[T", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "]T", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      ---@diagnostic enable: undefined-field
    },
  },
}
