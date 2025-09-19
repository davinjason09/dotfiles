return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
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
      server_opts_overrides = {
        settings = {
          telemetry = {
            telemetryLevel = "off",
          },
        },
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      local function map(mode, lhs, rhs)
        mode = mode or "n"
        vim.keymap.set(mode, lhs, rhs, { expr = true })
      end

      local suggestion = require("copilot.suggestion")
      map("i", "<C-Right>", function()
        if suggestion.is_visible() then return suggestion.accept_word() end
        return "<C-Right>"
      end)
      map("i", "<C-Down>", function()
        if suggestion.is_visible() then return suggestion.accept_line() end
        return "<C-Down>"
      end)
    end,
  },
}
