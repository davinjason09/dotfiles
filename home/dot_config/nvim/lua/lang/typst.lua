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
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "tinymist",
        "typstyle",
        "bibtex-tidy",
      },
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    cmd = { "TypstPreview", "TypstPreviewToggle", "TypstPreviewUpdate" },
    -- stylua: ignore
    keys = {
      { "<leader>cp", "<CMD>TypstPreviewToggle<CR>", desc = "[C]ode: [P]review", ft = "typst" },
    },
    opts = {
      dependencies_bin = {
        tinymist = "tinymist",
      },
    },
  },
}
