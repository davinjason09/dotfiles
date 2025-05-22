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
        blink_cmp = true,
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
          -- blink.cmp
          BlinkCmpMenu                = { fg = colors.none,     bg = colors.base },
          BlinkCmpMenuBorder          = { fg = colors.overlay1, bg = colors.base },
          BlinkCmpDoc                 = { fg = colors.none,     bg = colors.base },
          BlinkCmpDocBorder           = { fg = colors.overlay1, bg = colors.base },
          BlinkCmpSignatureHelp       = { fg = colors.none,     bg = colors.base },
          BlinkCmpSignatureHelpBorder = { fg = colors.overlay1, bg = colors.base },
          BlinkCmpLabelMatch          = { fg = colors.green,    bg = colors.none, style = { "bold" } },
          BlinkCmpMenuSelection       = { fg = colors.mantle,   bg = colors.green },
          BlinkCmpKindKeyword         = { link = "Keyword" },

          -- noice.nvim
          NoiceConfirmBorder = { fg = colors.sky },

          NoiceCmdlinePopupBorderCmdline    = { fg = colors.sky },
          NoiceCmdlinePopupBorderSearch     = { fg = colors.yellow },
          NoiceCmdlinePopupBorderFilter     = { fg = colors.peach },
          NoiceCmdlinePopupBorderCalculator = { fg = colors.green },
          NoiceCmdlinePopupBorderHelp       = { fg = colors.blue },
          NoiceCmdlinePopupBorderLua        = { fg = colors.mauve },
          NoiceCmdlinePopupBorderInput      = { fg = colors.lavender },

          NoiceCmdlinePopupTitleCmdline     = { fg = colors.mantle, bg = colors.sky },
          NoiceCmdlinePopupTitleSearch      = { fg = colors.mantle, bg = colors.yellow },
          NoiceCmdlinePopupTitleFilter      = { fg = colors.mantle, bg = colors.peach },
          NoiceCmdlinePopupTitleCalculator  = { fg = colors.mantle, bg = colors.green },
          NoiceCmdlinePopupTitleHelp        = { fg = colors.mantle, bg = colors.blue },
          NoiceCmdlinePopupTitleLua         = { fg = colors.mantle, bg = colors.mauve },
          NoiceCmdlinePopupTitleInput       = { fg = colors.mantle, bg = colors.lavender },
        }
      end,
    })

    local palette = require("catppuccin.palettes").get_palette()
    Defaults.filling_palette(palette)
  end,
}
