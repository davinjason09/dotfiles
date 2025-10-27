return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "markdown",
        "markdown_inline",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "marksman",
        "prettier",
      },
    },
  },
  {
    "brianhuster/live-preview.nvim",
    dependencies = { "folke/snacks.nvim" },
    ft = { "markdown" },
    cmd = { "LivePreview" },
    keys = function(plugin)
      return {
        {
          "<leader>cp",
          function()
            vim.cmd("LivePreview " .. (require("livepreview").is_running() and "close" or "start"))
          end,
          desc = "[C]ode: [P]review",
          ft = plugin.ft,
        },
      }
    end,
    opts = { dynamic_root = true },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ft = { "markdown" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      enabled = true,
      file_types = { "markdown", "blink-cmp-documentation" },
      completions = { blink = { enabled = true } },
      render_modes = true,
      checkbox = {
        checked = { icon = "", scope_highlight = "@markup.strikethrough" },
        unchecked = { icon = "" },
        -- stylua: ignore
        custom = {
          inprogress = { raw = "[~]", rendered = "", highlight = "RenderMarkdownH6" },
          pending    = { raw = "[/]", rendered = "󱫫", highlight = "RenderMarkdownH2" },
          cancelled  = { raw = "[-]", rendered = "", highlight = "RenderMarkdownError" },
          starred    = { raw = "[*]", rendered = "", highlight = "RenderMarkdownH3" },
          bookmark   = { raw = "[b]", rendered = "", highlight = "RenderMarkdownH2" },
          question   = { raw = "[?]", rendered = "", highlight = "RenderMarkdownHint" },
          info       = { raw = "[i]", rendered = "", highlight = "RenderMarkdownInfo" },
          warning    = { raw = "[!]", rendered = "", highlight = "RenderMarkdownHint" },
        },
      },
      code = {
        position = "right",
        width = "block",
        min_width = 45,
        left_margin = 1,
        left_pad = 2,
        language_pad = 1,
        inline_pad = 1,
        right_pad = 10,
        border = "thin",
      },
      heading = {
        icons = function(ctx)
          local icons = { "󰎥 ", "󰎨 ", "󰎫 ", "󰎲 ", "󰎯 ", "󰎴 " }

          if ctx.sections[0] then return "" end -- Disable icons for setex heading

          return icons[ctx.level] or "󱧓 "
        end,
        border = true,
        border_virtual = true,
      },
      bullet = {
        -- stylua: ignore
        icons = {
          { "󰯫", "󰯮", "󰯱", "󰯴", "󰯷", "󰯺", "󰯽", "󰰀", "󰰃", "󰰆", "󰰉", "󰰌", "󰰏", "󰰒", "󰰕", "󰰘", "󰰛", "󰰞", "󰰡", "󰰤", "󰰧", "󰰪", "󰰭", "󰰰", "󰰳", "󰰶" },
          "●", "○", "◆", "◇", "󰨓", "󰨔"
        },
      },
      pipe_table = {
        preset = "round",
        min_width = 2,
      },
      quote = { repeat_linebreak = true },
      html = { comment = { conceal = false } },
      win_options = {
        showbreak = {
          default = "",
          rendered = "  ",
        },
        breakindent = {
          default = false,
          rendered = true,
        },
        breakindentopt = {
          default = "",
          rendered = "",
        },
        conceallevel = { default = 0, rendered = 2 },
      },
      latex = { enabled = false },
      overrides = {
        buftype = {
          nofile = {
            anti_conceal = { enabled = false },
            code = {
              border = "thick",
              position = "left",
              width = "full",
              left_margin = 0,
              left_pad = 0,
              language_pad = 0,
              right_pad = 0,
            },
            debounce = 5,
            win_options = {
              concealcursor = { default = "", rendered = "nvic" },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      Snacks.toggle({
        name = "Render Markdown",
        get = function() return require("render-markdown.state").enabled end,
        set = function(enabled)
          local m = require("render-markdown")
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      }):map("<leader>um")
    end,
  },
}
