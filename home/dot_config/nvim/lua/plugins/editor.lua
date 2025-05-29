return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ignored_next_char = "[%w%.]",
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      local rule = require("nvim-autopairs.rule")
      local ts_conds = require("nvim-autopairs.ts-conds")

      npairs.setup(opts)

      npairs.add_rules({
        rule("{", "},", "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
        rule("'", "',", "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
        rule('"', '",', "lua"):with_pair(ts_conds.is_ts_node({ "table_constructor" })),
        rule('"""', '"""'),
        rule("'''", "'''"),
        rule("```", "```", { "markdown", "typst" }),
        rule("$", "$", { "typst", "latex" }),
        rule("_", "_", "typst"),
        rule("*", "*", "typst"),
        rule("~", "~", "typst"),
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      triggers = {
        { "<auto>", mode = "nxso" },
        { "s", mode = "nx" },
      },
      win = {
        width = { min = 10, max = 40 },
        height = { min = 4, max = 0.75 },
        padding = { 0, 1 },
        col = -1,
        row = -1,
        border = "rounded",
        title = true,
        title_pos = "left",
      },
      layout = {
        width = { min = 10, max = 40 },
      },
      icons = {
        rules = {
          { pattern = "%f[%a]%[?g%]?it", cat = "filetype", name = "git" },
          { pattern = "lazy", cat = "filetype", name = "lazy" },

          { icon = " ", pattern = "profiler", color = "yellow" },
          { icon = " ", pattern = "toggle", color = "yellow" },
          { icon = "󱀢 ", pattern = "c%]?omment", color = "yellow" },
          { icon = "󰆏 ", pattern = "yank", color = "orange" },
          { icon = "󰅌 ", pattern = "paste", color = "orange" },
          { icon = "󱈅 ", pattern = "visual selection", color = "green" },
          { icon = "󰼢 ", pattern = "visual", color = "purple" },

          { icon = " ", pattern = "c%]?md", color = "orange" },
          { icon = " ", pattern = "c%]?olor", color = "azure" },
          { icon = " ", pattern = "c%]?ommand", color = "orange" },
          { icon = " ", pattern = "c%]?onfig", color = "red" },
          { icon = "󱖫 ", pattern = "diagnostics", color = "green" },
          { icon = " ", pattern = "%f[%a/%p]%[?f%]?ile", color = "cyan" },
          { icon = "󱩾 ", pattern = "g%]?rep", color = "green" },
          { icon = " ", pattern = "h%]?ighlight", color = "purple" },
          { icon = " ", pattern = "i%]?con", color = "yellow" },
          { icon = "󰜎 ", pattern = "j%]?ump", color = "orange" },
          { icon = " ", pattern = "k%]?eymap", color = "yellow" },
          { icon = " ", pattern = "%f[%a]%[?l%]?ine", color = "cyan" },
          { icon = "󱖫 ", pattern = "l%]?ocation list", color = "green" },
          { icon = "󰸕 ", pattern = "m%]?ark%f[%a]", color = "orange" },
          { icon = "󰪻 ", pattern = "p%]?roject", color = "cyan" },
          { icon = "󱖫 ", pattern = "q%]?uickfix", color = "green" },
          { icon = "󱋢 ", pattern = "r%]?ecent", color = "cyan" },
          { icon = " ", pattern = "r%]?egister", color = "orange" },
          { icon = " ", pattern = "r%]?eplace", color = "red" },
          { icon = "󱩾 ", pattern = "r%]?esume", color = "green" },
          { icon = " ", pattern = "t%]?erminal", color = "red" },
          { icon = " ", pattern = "t%]?odo", color = "purple" },
          { icon = "󰙅 ", pattern = "u%]?ndotree", color = "orange" },
          { icon = " ", pattern = "w%]?ord", color = "yellow" },

          { icon = " ", pattern = "b%]?uffer", color = "cyan" },
          { icon = "󰙅 ", pattern = "e%]?xplorer", color = "green" },
          { icon = "󰙵 ", pattern = "%f[%a]ui", color = "cyan" },
          { icon = " ", pattern = "%f[%a]new tab", color = "blue" },
          { icon = " ", pattern = "%f[%a]new%f[%a]", color = "cyan" },

          { icon = "󰘥 ", pattern = "%f[%a]h%]?elp", color = "green" },
          { icon = "󰘥 ", pattern = "%f[%a]m%]?an", color = "green" },
          { icon = "󰘥 ", pattern = "%f[%a]keywordprg", color = "green" },
          { icon = " ", pattern = "f%]?ind", color = "green" },
          { icon = " ", pattern = "s%]?earch", color = "green" },
          { icon = " ", pattern = "f%]?ormat", color = "cyan" },

          { icon = " ", plugin = "persistence.nvim", color = "azure" },

          { icon = " ", pattern = "window", color = "blue" },
          { icon = "󱅫 ", pattern = "notif", color = "blue" },
          { icon = " ", pattern = "inspect", color = "red" },
          { icon = " ", pattern = "align", color = "cyan" },
          { icon = " ", pattern = "add", color = "green" },
          { icon = " ", pattern = "delete", color = "red" },
          { icon = "󱅅 ", pattern = "update", color = "yellow" },
          { icon = "󱅅 ", pattern = "change", color = "yellow" },
          { icon = " ", pattern = "last", color = "blue" },
          { icon = " ", pattern = "prev", color = "blue" },
          { icon = " ", pattern = "next", color = "blue" },
          { icon = " ", pattern = "up$", color = "blue" },
          { icon = " ", pattern = "%f[%a]down", color = "blue" },
          { icon = " ", pattern = "left", color = "blue" },
          { icon = " ", pattern = "right", color = "blue" },
        },
      },
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>E", group = "explorer" },
          { "<leader>f", group = "find/file" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>sn", group = "noice" },
          { "<leader>u", group = "ui" },
          { "<leader>x", group = "diagnostics/quickfix" },
          {
            "<leader>b",
            group = "buffer",
            expand = function() return require("which-key.extras").expand.buf() end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<C-w>",
            expand = function() return require("which-key.extras").expand.win() end,
          },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gc", group = "comment" },
          { "s", group = "surround" },
          { "z", group = "fold" },
        },
        { "sn", desc = "Update `n` lines" },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps (which-key)", },
      { "<C-w><Space>", function() require("which-key").show({ keys = "<C-w>", loop = true }) end, desc = "Window Hydra Mode (which-key)", },
    },
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {},
    -- stylua: ignore
    keys = {
      ---@diagnostic disable-next-line: undefined-field
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "[S]earch [T]ODO", },
      ---@diagnostic disable-next-line: undefined-field
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "[S]earch [T]ODO/FIX/FIXME", },
      { "[T", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "]T", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
    },
  },
}
