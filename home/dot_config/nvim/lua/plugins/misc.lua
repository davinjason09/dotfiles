return {
  {
    "LudoPinelli/comment-box.nvim",
    event = "InsertEnter",
    opts = {
      doc_width = 80,
      box_width = 60,
      line_width = 70,
    },
    -- stylua: ignore
    keys = {
      { "gcb", ":CBccbox<CR>",    desc = "[C]omment - [B]ox",        mode = { "n", "v" } },
      { "gct", ":CBllline12<CR>", desc = "[C]omment - [T]itle Line", mode = { "n", "v" } },
      { "gcl", ":CBlline<CR>",    desc = "[C]omment - [L]ine",       mode = { "n", "v" } },
      { "gcm", ":CBllbox14<CR>",  desc = "[C]omment - [M]arked",     mode = { "n", "v" } },
      { "gcd", ":CBd<CR>",        desc = "[C]omment - [D]elete",     mode = { "n", "v" } },
    },
  },
  {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = "VeryLazy",
    opts = {
      editor = { tooltip = "I use Neovim btw" },
      log_level = vim.log.levels.OFF,
      display = {
        theme = "atom",
        flavor = "accent",
      },
      hooks = {
        ---@diagnostic disable-next-line: unused-vararg
        ready = function(...) vim.notify("  Connected to Discord!") end,
      },
    },
  },
  { "nvzone/volt" },
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    opts = {
      timeout = 1,
      maxkeys = 5,
      show_count = true,
      winopts = { border = "rounded" },
      keyformat = {
        ["<CR>"] = "󰌑",
        ["<C>"] = "󰘴",
        ["<M>"] = "󰘵",
        ["<D>"] = "󰘳",
      },
    },
  },
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
}
