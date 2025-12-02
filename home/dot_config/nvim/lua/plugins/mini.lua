return {
  {
    "nvim-mini/mini.surround",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = { n_lines = 50 },
  },
  {
    "nvim-mini/mini.align",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "nvim-mini/mini.move",
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
    "nvim-mini/mini.ai",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local ai = require("mini.ai")
      local ts = ai.gen_spec.treesitter
      local pr = ai.gen_spec.pair
      local fc = ai.gen_spec.function_call

      return {
        n_lines = 500,
        custom_textobjects = {
          b = { { "%b()", "%b[]", "%b{}" }, "^.%s*().-()%s*.$" }, -- remove whitespace from `i` textobject
          B = { { "%b()", "%b[]", "%b{}" }, "^.().*().$" },
          c = ts({ a = "@class.outer", i = "@class.inner" }), -- class
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
          f = ts({ a = "@function.outer", i = "@function.inner" }), -- function
          g = Utils.mini.ai.buffer, -- whole buffer
          o = ts({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          u = fc(), -- u for "Usage"
          U = fc({ name_pattern = "[%w_]" }), -- without dot in function name
          ["*"] = pr("*", "*", { type = "greedy" }),
          ["_"] = pr("_", "_", { type = "greedy" }),
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
    "nvim-mini/mini.icons",
    version = "*",
    -- stylua: ignore
    opts = {
      default = {
        directory = { glyph = "", hl = "MiniIconsBlue" },
        file      = { glyph = "" },
        filetype  = { glyph = "" },
      },
      file = {
        PKGBUILD                = { glyph = "", hl = "MiniIconsYellow" },
        README                  = { glyph = "󰂺", hl = "MiniIconsYellow" },
        [".eslintrc.js"]        = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".gitconfig"]          = { glyph = "󰊢", hl = "MiniIconsOrange" },
        [".keep"]               = { glyph = "󰊢", hl = "MiniIconsGrey" },
        [".histfile"]           = { glyph = "", hl = "Conceal" },
        [".node-version"]       = { glyph = "", hl = "MiniIconsGreen" },
        [".node_repl_history"]  = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"]         = { glyph = "", hl = "MiniIconsPurple" },
        [".python-version"]     = { glyph = "", hl = "MiniIconsGreen" },
        [".yarnrc.yml"]         = { glyph = "", hl = "MiniIconsBlue" },
        [".zcompdump"]          = { glyph = "", hl = "MiniIconsYellow" },
        ["README.md"]           = { glyph = "󰂺", hl = "MiniIconsYellow" },
        ["README.txt"]          = { glyph = "󰂺", hl = "MiniIconsYellow" },
        ["devcontainer.json"]   = { glyph = "", hl = "MiniIconsAzure" },
        ["eslint.config.js"]    = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["init.lua"]            = { glyph = "", hl = "MiniIconsGreen" },
        ["package.json"]        = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.json"]       = { glyph = "", hl = "MiniIconsAzure" },
        ["wezterm.lua"]         = { glyph = "", hl = "MiniIconsPurple" },
        ["yarn.lock"]           = { glyph = "", hl = "MiniIconsBlue" },
        nu                      = { glyph = "", hl = "MiniIconsGreen" },
        -- tui
        lazygit = { glyph = "󰒲", hl = "MiniIconsOrange" },
        btop    = { glyph = "", hl = "MiniIconsRed" },
      },
      filetype = {
        awk    = { glyph = "", hl = "MiniIconsGrey" },
        bash   = { glyph = "", hl = "MiniIconsGreen" },
        c      = { glyph = "", hl = "MiniIconsAzure" },
        cpp    = { glyph = "", hl = "MiniIconsAzure" },
        css    = { glyph = "", hl = "MiniIconsPurple" },
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        elvish = { glyph = "󰘧", hl = "MiniIconsGreen" },
        fish   = { glyph = "", hl = "MiniIconsGreen" },
        gotmpl = { glyph = "", hl = "MiniIconsGrey" },
        nu     = { glyph = "", hl = "MiniIconsGreen" },
        ps1    = { glyph = "", hl = "MiniIconsBlue" },
        psxml  = { glyph = "", hl = "MiniIconsAzure" },
        sh     = { glyph = "", hl = "MiniIconsGrey" },
        tcsh   = { glyph = "󱄽", hl = "MiniIconsAzure" },
        typ    = { glyph = "", hl = "MiniIconsAzure" },
        typc   = { glyph = "", hl = "MiniIconsAzure" },
        typst  = { glyph = "", hl = "MiniIconsAzure" },
        yaml   = { glyph = "", hl = "MiniIconsPurple" },
        zsh    = { glyph = "", hl = "MiniIconsGreen" },
      },
      extension = {
        c    = { glyph = "", hl = "MiniIconsAzure" },
        cpp  = { glyph = "", hl = "MiniIconsAzure" },
        bak  = { glyph = "󰁯", hl = "Conceal" },
        h    = { glyph = "󰬏", hl = "MiniIconsPurple" },
        log  = { glyph = "", hl = "Conceal" },
        lnk  = { glyph = "", hl = "Special" },
        nss  = { glyph = "", hl = "MiniIconsRed" },
        onnx = { glyph = "󱁊", hl = "MiniIconsGrey" },
        typ  = { glyph = "", hl = "MiniIconsAzure" },
        yml  = { glyph = "", hl = "MiniIconsPurple" },
        zwc  = { glyph = "", hl = "MiniIconsYellow" },
      }
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
