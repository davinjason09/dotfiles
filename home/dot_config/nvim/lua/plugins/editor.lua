return {
  {
    "windwp/nvim-autopairs",
    event = { "BufReadPost", "BufNewFile", "InsertEnter" },
    opts = {
      check_ts = true,
      ignored_next_char = "[%w%.]",
      fast_wrap = {},
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup(opts)

      npairs.add_rules({
        -- add space on both sides if inside a bracket
        Rule(" ", " "):with_pair(cond.not_filetypes({ "markdown" })):with_pair(function(o)
          local after_cond = cond.after_regex("[%}%]%)]")
          local before_cond = cond.before_regex("[%{%[%(]")
          return after_cond(o) and before_cond(o)
        end),
      })
    end,
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
      ---@diagnostic disable-next-line: undefined-field
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "[S]earch [T]ODO", },
      ---@diagnostic disable-next-line: undefined-field
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "[S]earch [T]ODO/FIX/FIXME", },
      { "[T", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "]T", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
    },
  },
}
