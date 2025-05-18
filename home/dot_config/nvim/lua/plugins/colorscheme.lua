return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      term_colors = true,
      compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
      styles = {
        comments = { "italic" },
        functions = { "bold" },
        operators = { "bold" },
        conditionals = { "bold" },
        loops = { "bold" },
        booleans = { "bold" },
      },
      default_integrations = false,
      integrations = {
        mini = { enabled = true },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
          inlay_hints = {
            background = true,
          },
        },
        noice = true,
        snacks = {
          enabled = true,
          indent_scope_color = "sky",
        },
        treesitter = true,
        which_key = true,
      },
      custom_highlights = function(colors)
        -- stylua: ignore
        return {
          NoiceCmdlinePopupBorderCmdline = { fg = colors.sky },
          NoiceCmdlinePopupBorderSearch = { fg = colors.yellow },
          NoiceCmdlinePopupBorderFilter = { fg = colors.peach },
          NoiceCmdlinePopupBorderCalculator = { fg = colors.green },
          NoiceCmdlinePopupBorderHelp = { fg = colors.blue },
          NoiceCmdlinePopupBorderLua = { fg = colors.mauve },

          NoiceCmdlinePopupTitleCmdline = { fg = colors.mantle, bg = colors.sky },
          NoiceCmdlinePopupTitleSearch = { fg = colors.mantle, bg = colors.yellow },
          NoiceCmdlinePopupTitleFilter = { fg = colors.mantle, bg = colors.peach },
          NoiceCmdlinePopupTitleCalculator = { fg = colors.mantle, bg = colors.green },
          NoiceCmdlinePopupTitleHelp = { fg = colors.mantle, bg = colors.blue },
          NoiceCmdlinePopupTitleLua = { fg = colors.mantle, bg = colors.mauve },
        }
      end,
    })

    local palette = require("catppuccin.palettes").get_palette()
    Defaults.filling_palette(palette)
  end,
}
