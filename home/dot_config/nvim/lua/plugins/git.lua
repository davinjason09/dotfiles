return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      changedelete = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      changedelete = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
    },
    current_line_blame = true,
    current_line_blame_formatter = "<author> • <author_time:%R> • <summary> ",
    preview_config = { border = "rounded" },
    on_attach = function(buffer)
      local gs = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
      end

      -- Navigation
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      -- Actions
      map("n", "<leader>gp", gs.preview_hunk_inline, "[G]it: [P]review Hunk")
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "[G]it: [B]lame Line")
      map("n", "<leader>gB", gs.blame_line, "[G]it: [B]lame Buffer")
      map("n", "<leader>gd", gs.diffthis, "[G]it: [D]iff This")
      map("n", "<leader>gD", function() gs.diffthis("~") end, "[G]it: [D]iff This (~)")
      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Git Hunk")
    end,
  },
}
