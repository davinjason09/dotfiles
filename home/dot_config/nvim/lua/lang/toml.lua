return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "toml" },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "taplo" },
    },
  },
}
