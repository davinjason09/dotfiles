return {
  {
    "echasnovski/mini.surround",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = { n_lines = 50 },
  },
  {
    "echasnovski/mini.align",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "echasnovski/mini.move",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- stylua: ignore
    keys = {
      { "<", "<CMD>lua MiniMove.move_selection('left')<CR>", desc = "Move selection left", mode = { "v", "x" }, },
      { ">", "<CMD>lua MiniMove.move_selection('right')<CR>", desc = "Move selection right", mode = { "v", "x" }, },
      { "<<", "<CMD>lua MiniMove.move_line('left')<CR>", desc = "Move line left" },
      { ">>", "<CMD>lua MiniMove.move_line('right')<CR>", desc = "Move line right" },
    },
  },
  {
    "echasnovski/mini.pairs",
    version = "*",
    event = "InsertEnter",
    opts = {},
  },
  {
    "echasnovski/mini.ai",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local ai = require("mini.ai")

      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
  },
  {
    "echasnovski/mini.icons",
    version = "*",
    -- stylua: ignore
    opts = {
      default = {
        directory = { glyph = "", hl = "MiniIconsBlue" },
        file      = { glyph = "󰈚" },
        filetype  = { glyph = "󰈚" },
      },
      file = {
        README                  = { glyph = "󰂺", hl = "MiniIconsYellow" },
        [".eslintrc.js"]        = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".keep"]               = { glyph = "󰊢", hl = "MiniIconsGrey" },
        [".node-version"]       = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"]         = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"]         = { glyph = "", hl = "MiniIconsBlue" },
        ["devcontainer.json"]   = { glyph = "", hl = "MiniIconsAzure" },
        ["eslint.config.js"]    = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["package.json"]        = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.json"]       = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"]           = { glyph = "", hl = "MiniIconsBlue" },
        ["README.md"]           = { glyph = "󰂺", hl = "MiniIconsYellow" },
        ["README.txt"]          = { glyph = "󰂺", hl = "MiniIconsYellow" },
      },
      filetype = {
        awk    = { glyph = "", hl = "MiniIconsGrey" },
        bash   = { glyph = "", hl = "MiniIconsGreen" },
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        elvish = { glyph = "󰘧", hl = "MiniIconsGreen" },
        fish   = { glyph = "", hl = "MiniIconsGreen" },
        nu     = { glyph = "", hl = "MiniIconsGreen" },
        ps1    = { glyph = "", hl = "MiniIconsBlue" },
        psxml  = { glyph = "", hl = "MiniIconsAzure" },
        sh     = { glyph = "", hl = "MiniIconsGrey" },
        tcsh   = { glyph = "󱄽", hl = "MiniIconsAzure" },
        zsh    = { glyph = "", hl = "MiniIconsGreen" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
