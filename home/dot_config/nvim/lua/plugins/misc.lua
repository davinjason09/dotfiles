return {
  {
    "LudoPinelli/comment-box.nvim",
    opts = {
      doc_width = 80,
      box_width = 60,
      line_width = 70,
    },
    -- stylua: ignore
    keys = {
      { "gcb", "<CMD>CBccbox<CR>",    desc = "[C]omment - [B]ox",        mode = { "n", "x" } },
      { "gct", "<CMD>CBllline12<CR>", desc = "[C]omment - [T]itle Line", mode = { "n", "x" } },
      { "gcl", "<CMD>CBlline<CR>",    desc = "[C]omment - [L]ine",       mode = { "n", "x" } },
      { "gcm", "<CMD>CBllbox14<CR>",  desc = "[C]omment - [M]arked",     mode = { "n", "x" } },
      { "gcd", "<CMD>CBd<CR>",        desc = "[C]omment - [D]elete",     mode = { "n", "x" } },
    },
  },
  {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = { "BufReadPost", "BufNewFile" },
    version = "*",
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
