local M = {
  last_term = nil, ---@type integer?
  term_bufs = {}, ---@type TermBuf[]
  last_win = nil, ---@type string?
  buf_to_clear = {}, ---@type integer[]

  config = {
    ---@type snacks.picker.layout.Config
    picker_layout = {
      auto_hide = { "input" },
      hidden = { "input" },
      layout = {
        box = "horizontal",
        width = 0.9,
        min_width = 80,
        height = 0.9,
        {
          box = "vertical",
          border = "rounded",
          width = 0.1,
          min_width = 20,
          title = "{live} {flags}",
          { win = "input", height = 1, border = "bottom" },
          { win = "list" },
        },
        { win = "preview", title = "{preview}", border = "rounded" },
      },
    },
    keys = {
      input = {
        ["<C-`>"] = { "close", mode = { "n", "i", "x" } },
        ["<C-S-`>"] = { "toggle_persist", mode = { "n", "t", "x" } },
        ["<C-j>"] = { { "clear_input", "focus_list" }, mode = { "n", "i" } },
        ["<C-l>"] = { { "clear_input", "focus_term" }, mode = { "n", "i" } },
        ["d"] = { "delete_term", desc = "Delete Terminal" },
        ["a"] = { "add_term", desc = "Add Terminal" },
        ["A"] = { "add_term_cmd", desc = "Add Terminal with Command" },
        ["e"] = { "rename_term", desc = "Edit Terminal Name" },
        ["r"] = { "rename_term", desc = "Edit Terminal Name" },
      },
      list = {
        ["<C-`>"] = { "close", mode = { "n", "i" } },
        ["<C-S-`>"] = { "toggle_persist", mode = { "n", "t", "x" } },
        ["<C-k>"] = { "focus_input" },
        ["<C-l>"] = { "focus_term" },
        ["<Right>"] = { "focus_term" },
        ["a"] = { "add_term", desc = "Add Terminal" },
        ["A"] = { "add_term_cmd", desc = "Add Terminal with Command" },
        ["d"] = { "delete_term", desc = "Delete Terminal" },
        ["e"] = { "rename_term", desc = "Edit Terminal Name" },
        ["r"] = { "rename_term", desc = "Edit Terminal Name" },
      },
      preview = {
        ["<C-`>"] = { "close", mode = { "n", "t", "x" } },
        ["<C-S-`>"] = { "toggle_persist", mode = { "n", "t", "x" } },
        ["<C-h>"] = { { "focus_list", "stopinsert" }, mode = { "n", "t" } },
        ["<A-j>"] = { "cycle_next", desc = "Cycle to Next Terminal", mode = { "n", "t" } },
        ["<A-k>"] = { "cycle_prev", desc = "Cycle to Prev Terminal", mode = { "n", "t" } },
        ["<Down>"] = { "cycle_next", desc = "Cycle to Next Terminal", mode = { "n" } },
        ["<Up>"] = { "cycle_prev", desc = "Cycle to Prev Terminal", mode = { "n" } },
        ["<Left>"] = { { "focus_list", "stopinsert" }, desc = "Go to Terminal List", mode = { "n" } },
        ["<ESC>"] = { "term_normal", mode = { "t" }, expr = true },
        ["gf"] = { "goto_file", desc = "Go to file under the cursor" },
        ["i"] = { "startinsert", desc = "Insert", mode = { "n" } },
        ["a"] = { "add_term", desc = "Add Terminal", mode = { "n" } },
        ["A"] = { "add_term_cmd", desc = "Add Terminal with Command", mode = { "n" } },
        ["e"] = { "rename_term", desc = "Edit Terminal Name", mode = { "n" } },
        ["r"] = { "rename_term", desc = "Edit Terminal Name" },
      },
    },
  },
}

return M
