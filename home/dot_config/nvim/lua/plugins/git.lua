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
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
      end

      -- Navigation
      ---@diagnostic disable: param-type-mismatch
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd("normal! [c")
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd("normal! ]c")
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      -- Actions
      map("n", "<leader>ghp", gs.preview_hunk_inline, "[G]it [H]unk: [P]review Hunk")
      -- stylua: ignore
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "[G]it [H]unk: [B]lame Line")
      map("n", "<leader>ghB", gs.blame, "[G]it [H]unk: [B]lame Buffer")
      map("n", "<leader>ghd", gs.diffthis, "[G]it [H]unk: [D]iff This")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "[G]it [H]unk: [D]iff This (~)")
      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Git Hunk")
      ---@diagnostic enable: param-type-mismatch
    end,
  },
}
