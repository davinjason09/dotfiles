return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "vimdoc" },
    },
  },
  {
    "OXY2DEV/helpview.nvim",
    ft = "help",
    cmd = { "Help", "H", "Helpview" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      preview = {
        preview_winopts = {
          width = math.max(100, math.floor(vim.o.columns * 0.6)),
        },
      },
    },
  },
}
