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
        gitsigns = true,
        markdown = true,
        mason = true,
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
          inlay_hints = { background = true },
        },
        noice = true,
        render_markdown = true,
        semantic_tokens = true,
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
          NoiceConfirmTitle  = { fg = colors.mantle, bg = colors.sky },

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

          -- snacks.nvim
          SnacksNormal              = { fg = colors.text,      bg = colors.mantle },
          SnacksPicker              = { fg = colors.none,      bg = colors.mantle },
          SnacksPickerBorder        = { fg = colors.sky,       bg = colors.mantle },
          SnacksPickerTitle         = { fg = colors.subtext0,  bg = colors.mantle,   style = { "bold" } },
          SnacksPickerSelected      = { fg = colors.text,      bg = colors.surface0, style = { "bold" } },
          SnacksPickerMatch         = { fg = colors.sky,       bg = colors.none,     style = { "bold" } },
          SnacksWinBorder           = { fg = colors.sky,       bg = colors.mantle },
          SnacksTerminalNormal      = { fg = colors.text,      bg = colors.mantle },
          SnacksTerminalBorder      = { fg = colors.sky,       bg = colors.mantle },
          SnacksNotifierInfo        = { fg = colors.blue,      bg = colors.mantle },
          SnacksNotifierWarn        = { fg = colors.yellow,    bg = colors.mantle },
          SnacksNotifierError       = { fg = colors.red,       bg = colors.mantle },
          SnacksNotifierDebug       = { fg = colors.peach,     bg = colors.mantle },
          SnacksNotifierTrace       = { fg = colors.rosewater, bg = colors.mantle },
          SnacksNotifierIconInfo    = { link = "SnacksNotifierInfo" },
          SnacksNotifierIconWarn    = { link = "SnacksNotifierWarn" },
          SnacksNotifierIconError   = { link = "SnacksNotifierError" },
          SnacksNotifierIconDebug   = { link = "SnacksNotifierDebug" },
          SnacksNotifierIconTrace   = { link = "SnacksNotifierTrace" },
          SnacksNotifierBorderInfo  = { link = "SnacksNotifierInfo" },
          SnacksNotifierBorderWarn  = { link = "SnacksNotifierWarn" },
          SnacksNotifierBorderError = { link = "SnacksNotifierError" },
          SnacksNotifierBorderDebug = { link = "SnacksNotifierDebug" },
          SnacksNotifierBorderTrace = { link = "SnacksNotifierTrace" },
          SnacksNotifierTitleInfo   = { fg = colors.blue,      bg = colors.mantle, style = { "italic" } },
          SnacksNotifierTitleWarn   = { fg = colors.yellow,    bg = colors.mantle, style = { "italic" } },
          SnacksNotifierTitleError  = { fg = colors.red,       bg = colors.mantle, style = { "italic" } },
          SnacksNotifierTitleDebug  = { fg = colors.peach,     bg = colors.mantle, style = { "italic" } },
          SnacksNotifierTitleTrace  = { fg = colors.rosewater, bg = colors.mantle, style = { "italic" } },

          -- mini.files
          MiniFilesBorder       = { fg = colors.sky,      bg = colors.mantle },
          MiniFilesTitle        = { fg = colors.subtext0, bg = colors.mantle },
          MiniFilesTitleFocused = { fg = colors.subtext0, bg = colors.mantle, style = { "bold" } },

          -- whichkey.nvim
          WhichKeyNormal = { fg = colors.text,     bg = colors.mantle },
          WhichKeyBorder = { fg = colors.sky,      bg = colors.mantle },
          WhichKeyTitle  = { fg = colors.subtext0, bg = colors.mantle },
          WhichKey       = { bg = colors.mantle },

          -- LSP Hover
          LSPHoverBorder = { fg = colors.overlay1, bg = colors.base },
          NormalFloat    = { bg = colors.base },
        }
      end,
    })

    local palette = require("catppuccin.palettes").get_palette()
    Defaults.filling_palette(palette)
  end,
}
