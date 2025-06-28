return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "luadoc",
        "luap",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
      },
    },
  },
  { "gonstoll/wezterm-types" },
  { "MaJinjie/yazi-meta.nvim" },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "blink.cmp", words = { "blink.cmp" } },
        { path = "wezterm-types", modes = { "wezterm" } },
        { path = "yazi-meta.nvim", words = { "ya", "cx", "ui" } },
        { path = "catppuccin" },
      },
    },
  },
}
