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
        ready = function(...)
          local msg = {
            { "  ", "DiscordBlurple" },
            { "Connected to Discord!", "@text" },
          }

          vim.api.nvim_set_hl(0, "DiscordBlurple", { fg = "#7289DA" })
          vim.api.nvim_echo(msg, false, { verbose = false })
        end,
      },
      advanced = {
        discord = {
          reconnect = {
            enabled = true,
            initial = true,
            interval = 3600 * 1000, -- Keep trying to reconnect for 1 hour
          },
        },
      },
    },
  },
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
}
