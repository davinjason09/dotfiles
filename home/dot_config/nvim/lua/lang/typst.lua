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
  {
    "pxwg/math-conceal.nvim",
    event = "BufReadPost *.typ",
    main = "math-conceal",
    opts = {
      conceal = {
        "greek",
        "script",
        "math",
        "font",
        "delim",
        "phy",
      },
      ft = { "bibtex", "typst" },
      highlights = {
        ["@conceal"] = { link = "@function" },
      },
    },
    config = function(_, opts)
      require("math-conceal").setup(opts)

      -- NOTE: for some reason, the Conceal highlight is gone, so redefine it here
      vim.schedule(function() vim.api.nvim_set_hl(0, "Conceal", { fg = Defaults.palette.overlay1 }) end)
    end,
  },
}
