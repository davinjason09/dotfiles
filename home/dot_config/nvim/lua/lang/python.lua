return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "python" },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "ruff" },
    },
  },
  -- possibly add uv.nvim
}
