local M = {}

local palette = dofile(Config .. "/palette.lua")

M.yatline = {
  section_separator = { open = "", close = "" },
  part_separator = { open = "", close = "" },
  inverse_separator = { open = "", close = "" },
  show_background = true,

  -- ╾╼ Styles ╾────────────────────────────────────────────────────────╼
  style_a = {
    fg = palette.crust,
    bg_mode = {
      normal = palette.blue,
      select = palette.mauve,
      un_set = palette.red,
    },
  },
  style_b = {
    fg = palette.text,
    bg = palette.surface1,
  },
  style_c = {
    fg = palette.text,
    bg = palette.crust,
  },

  permissions_t_fg = palette.blue,
  permissions_r_fg = palette.yellow,
  permissions_w_fg = palette.red,
  permissions_x_fg = palette.green,
  permissions_s_fg = palette.lavender,

  tab_width = 20,
  -- ╾╼ Icons ╾─────────────────────────────────────────────────────────╼
  -- stylua: ignore start
  selected  = { icon = "󰻭", fg = palette.yellow },
  copied    = { icon = "", fg = palette.green },
  cut       = { icon = "", fg = palette.red },
  total     = { icon = "󰮍", fg = palette.yellow },
  succ      = { icon = "", fg = palette.green },
  fail      = { icon = "", fg = palette.red },
  found     = { icon = "", fg = palette.blue },
  processed = { icon = "󰐍", fg = palette.green },
  -- stylua: ignore end

  -- ╾╼ Header line ╾───────────────────────────────────────────────────╼
  header_line = {
    left = {
      section_a = {
        { type = "coloreds", custom = true, name = { { " 󰇥 ", palette.yellow } } },
        { type = "line", custom = false, name = "tabs", params = { "left" } },
      },
      section_b = {},
      section_c = {},
    },
    right = {
      section_a = {
        { type = "string", custom = false, name = "tab_num_files" },
        { type = "coloreds", custom = true, name = { { " Total:", palette.crust } } },
      },
      section_b = {},
      section_c = {
        { type = "coloreds", custom = false, name = "task_workload" },
        { type = "coloreds", custom = false, name = "task_states" },
      },
    },
  },

  -- ╾╼ Status line ╾───────────────────────────────────────────────────╼
  status_line = {
    left = {
      section_a = {
        { type = "string", custom = false, name = "tab_mode" },
      },
      section_b = {
        { type = "coloreds", custom = false, name = "githead" },
      },
      section_c = {
        {
          type = "string",
          custom = false,
          name = "hovered_path",
          params = { { trimed = true, max_length = 24, trim_length = 10 } },
        },
      },
    },
    right = {
      section_a = {
        { type = "string", custom = false, name = "date", params = { "%H:%M" } },
      },
      section_b = {
        { type = "string", custom = false, name = "hovered_size" },
      },
      section_c = {
        { type = "coloreds", custom = false, name = "count", params = "true" },
        { type = "coloreds", custom = false, name = "permissions" },
      },
    },
  },
}

M.githead = {
  show_branch = true,
  branch_prefix = "",
  prefix_color = "",
  branch_color = palette.yellow,
  branch_symbol = "",
  branch_borders = "",

  -- NOTE:
  -- The options below should be show_behind_ahead, however it doesn't remove the
  -- behind/ahead section when set to false
  -- As it turns out, in the default config as seen on github, the option checks for
  -- `options.behind_ahead` and not `options.show_behind_ahead`
  behind_ahead = false,
  show_stashes = false,
  show_state = false,
  show_state_prefix = false,
  show_staged = false,
  show_unstaged = false,
  show_untracked = false,
}

return M
