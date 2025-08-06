return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false,
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = false,
        yaml = true,
      },
    },
    keys = {
      {
        "<C-Right>",
        function()
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").accept_word()
            return true
          end
          return "<C-Right>"
        end,
        mode = { "i" },
        expr = true,
      },
      {
        "<C-Down>",
        function()
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").accept_line()
            return true
          end
          return "<C-Down>"
        end,
        mode = { "i" },
        expr = true,
      },
    },
  },
}
