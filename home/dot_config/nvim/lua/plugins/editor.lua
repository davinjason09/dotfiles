return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
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
