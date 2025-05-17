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
}
