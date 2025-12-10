return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "typst",
        "bibtex",
      },
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    cmd = { "TypstPreview", "TypstPreviewToggle", "TypstPreviewUpdate" },
    -- stylua: ignore
    keys = {
      { "<leader>cP", "<CMD>TypstPreviewToggle<CR>", desc = "[C]ode: [P]review", ft = "typst" },
    },
    opts = {
      dependencies_bin = { tinymist = "tinymist" },
      port = 8124,
      get_main_file = function(path)
        if vim.g.typst_main_file then return vim.g.typst_main_file end

        return path
      end,
    },
  },
}
