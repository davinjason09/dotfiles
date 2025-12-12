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
  { "DrKJeff16/wezterm-types" },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "$LLS_Addons/luvit", words = { "vim%.uv", "uv" } },
        { path = "snacks.nvim", words = { "Snacks", "snacks" } },
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },
}
