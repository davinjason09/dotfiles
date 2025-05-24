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
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    -- stylua: ignore
    keys = {
      { "<leader>cp", "<CMD>MarkdownPreviewToggle<CR>", desc = "[C]ode: [P]review", ft = "markdown" },
    },
    config = function() vim.cmd([[do FileType]]) end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ft = { "markdown" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      enabled = true,
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
        icons = { "󰎥 ", "󰎨 ", "󰎫 ", "󰎲 ", "󰎯 ", "󰎴 " },
        border = true,
      },
      bullet = {
        -- stylua: ignore
        icons = {
          { "󰯫", "󰯮", "󰯱", "󰯴", "󰯷", "󰯺", "󰯽", "󰰀", "󰰃", "󰰆", "󰰉", "󰰌", "󰰏", "󰰒", "󰰕", "󰰘", "󰰛", "󰰞", "󰰡", "󰰤", "󰰧", "󰰪", "󰰭", "󰰰", "󰰳", "󰰶" },
          "", "●", "○", "◆", "◇",
        },
      },
      pipe_table = {
        preset = "round",
        min_width = 2,
      },
      quote = { repeat_linebreak = true },
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
            code = {
              border = "hide",
              position = "left",
              width = "full",
              left_margin = 0,
              left_pad = 0,
              language_pad = 0,
              right_pad = 0,
            },
            win_options = {
              concealcursor = { rendered = "nvic" },
            },
          },
        },
      },
    },
  },
}
