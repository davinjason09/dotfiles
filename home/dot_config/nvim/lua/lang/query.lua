return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "query" },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ts_query_ls",
      },
    },
  },
}
