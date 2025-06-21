return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "yaml" },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "yaml-language-server" },
    },
  },
}
