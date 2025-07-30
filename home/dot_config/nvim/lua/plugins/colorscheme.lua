return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  specs = {
    {
      "akinsho/bufferline.nvim",
      optional = true,
      opts = function(_, opts)
        if (vim.g.colors_name or ""):find("catppuccin") then
          opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
        end
      end,
    },
  },
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
          -- Syntax
          Identifier   = { fg = colors.text },
          PreProc      = { fg = colors.pink },
          Label        = { fg = colors.rosewater },
          Keyword      = { fg = colors.red },
          Exception    = { fg = colors.peach },
          Include      = { fg = colors.teal },
          Delimiter    = { fg = colors.teal },
          StorageClass = { link = "Keyword" },
          Structure    = { link = "Keyword" },
          Macro        = { link = "Constant" },

          ["@variable"]            = { link = "Identifier" },
          ["@variable.builtin"]    = { link = "Keyword" },
          ["@function.macro"]      = { link = "Constant" },
          ["@keyword.operator"]    = { link = "Operator" },

          ["@variable.parameter"]  = { fg = colors.rosewater },
          ["@variable.member"]     = { fg = colors.rosewater },
          ["@constant.builtin"]    = { fg = colors.lavender },
          ["@module"]              = { fg = colors.rosewater },
          ["@keyword.function"]    = { fg = colors.maroon },
          ["@keyword.return"]      = { fg = colors.pink },
          ["@variable.member.lua"] = { fg = colors.lavender },
          ["@namespace.builtin"]   = { fg = colors.red },

          ["@lsp.type.class"]                        = { link = "@type" },
          ["@lsp.type.event"]                        = { link = "@event" },
          ["@lsp.type.formatSpecifier"]              = { link = "@markup.link.label" },
          ["@lsp.type.interface"]                    = { link = "@type" },
          ["@lsp.type.modifier"]                     = { link = "@keyword" },
          ["@lsp.type.namespace"]                    = { link = "@module" },
          ["@lsp.type.parameter"]                    = { link = "@variable.parameter" },
          ["@lsp.type.property.cpp"]                 = { link = "@property.cpp" },
          ["@lsp.type.regex"]                        = { link = "@string.regexp" },
          ["@lsp.type.struct"]                       = { link = "@type" },
          ["@lsp.type.typeParameter"]                = { link = "@type" },
          ["@lsp.typemod.enum.defaultLibrary"]       = { link = "@type" },
          ["@lsp.typemod.enumMember.defaultLibrary"] = { link = "@constant" },
          ["@lsp.typemod.function.defaultLibrary"]   = { link = "@function" },
          ["@lsp.typemod.keyword.async"]             = { link = "@keyword" },
          ["@lsp.typemod.macro.defaultLibrary"]      = { link = "@constant.macro" },
          ["@lsp.typemod.method.defaultLibrary"]     = { link = "@function" },
          ["@lsp.typemod.type.defaultLibrary"]       = { link = "@type" },

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

          NoiceCmdline = { bg = colors.crust },

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
          SnacksExplorerTitle       = { fg = colors.blue,      bg = colors.mantle,   style = { "bold" } },
          SnacksNotifierInfo        = { fg = colors.sky,       bg = Snacks.util.blend(colors.sky, colors.base, 0.095) },
          SnacksNotifierWarn        = { fg = colors.yellow,    bg = Snacks.util.blend(colors.yellow, colors.base, 0.095) },
          SnacksNotifierError       = { fg = colors.red,       bg = Snacks.util.blend(colors.red, colors.base, 0.095) },
          SnacksNotifierDebug       = { fg = colors.peach,     bg = Snacks.util.blend(colors.peach, colors.base, 0.095) },
          SnacksNotifierTrace       = { fg = colors.rosewater, bg = Snacks.util.blend(colors.rosewater, colors.base, 0.095) },
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
          SnacksNotifierTitleInfo   = { link = "SnacksNotifierInfo" },
          SnacksNotifierTitleWarn   = { link = "SnacksNotifierWarn" },
          SnacksNotifierTitleError  = { link = "SnacksNotifierError" },
          SnacksNotifierTitleDebug  = { link = "SnacksNotifierDebug" },
          SnacksNotifierTitleTrace  = { link = "SnacksNotifierTrace" },
          SnacksNotifierFooterInfo  = { link = "SnacksNotifierInfo" },
          SnacksNotifierFooterWarn  = { link = "SnacksNotifierWarn" },
          SnacksNotifierFooterError = { link = "SnacksNotifierError" },
          SnacksNotifierFooterDebug = { link = "SnacksNotifierDebug" },
          SnacksNotifierFooterTrace = { link = "SnacksNotifierTrace" },

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
          FloatBorder    = { fg = colors.sky,      bg = colors.base },
          NormalFloat    = { bg = colors.base },

          -- Search
          Search    = { fg = colors.sky,      bg = colors.surface1, style = { "bold" } },
          IncSearch = { fg = colors.surface1, bg = colors.sky },

          -- BufferLine underline
          TabLineSel = { fg = colors.sky },

          -- QuickFix
          BqfPreviewSbar  = { bg = colors.sky },
          BqfPreviewTitle = { fg = colors.subtext0, style = { "bold" } },
          QuickFixLineNr  = { link = "qfLineNr" },
        }
      end,
    })

    local palette = require("catppuccin.palettes").get_palette()
    Defaults.filling_palette(palette)
  end,
}
