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
      { "<A-Down>", "<CMD>lua MiniMove.move_line('down')<CR>", desc = "Move line down", mode = "i" },
      { "<A-Up>", "<CMD>lua MiniMove.move_line('up')<CR>", desc = "Move line up", mode = "i" },
    },
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
          b = { { "%b()", "%b[]", "%b{}" }, "^.%s*().-()%s*.$" }, -- remove whitespace from `i` textobject
          B = { { "%b()", "%b[]", "%b{}" }, "^.().*().$" },
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
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
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          g = Utils.mini.ai.buffer, -- whole buffer
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      Utils.on_load("which-key.nvim", function()
        vim.schedule(function() Utils.mini.ai.whichkey(opts) end)
      end)
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
        ['init.lua']            = { glyph = "", hl = "MiniIconsGreen" },
        ["package.json"]        = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.json"]       = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"]           = { glyph = "", hl = "MiniIconsBlue" },
        ["README.md"]           = { glyph = "󰂺", hl = "MiniIconsYellow" },
        ["README.txt"]          = { glyph = "󰂺", hl = "MiniIconsYellow" },
        -- tui
        lazygit = { glyph = "󰒲", hl = "MiniIconsOrange" },
        btop    = { glyph = "", hl = "MiniIconsRed" },
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
        typ    = { glyph = "󰬛", hl = "MiniIconsAzure" },
        typc   = { glyph = "󰬛", hl = "MiniIconsAzure" },
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
