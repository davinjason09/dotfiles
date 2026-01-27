local t = {
  LEAF = "leaf",
  ROW = "row",
  COLUMN = "col",
}

local supported_win_types = {
  [t.LEAF] = true,
  [t.COLUMN] = true,
}

---@alias SidebarTitle { fg : string?, bg: string?, name: string | fun(win_id: integer): string }
---@type table<string, SidebarTitle>
local SIDEBAR_TITLE = {
  snacks_layout_box = {
    name = function(win_id)
      local pickers = Snacks.picker.get()
      if not pickers then return "" end

      for _, picker in ipairs(pickers) do
        if picker.layout.box_wins[1].win == win_id then
          if picker.title == "Explorer" then
            return "󰙅 File Explorer"
          elseif picker.title then
            return picker.title
          end
        end
      end

      return ""
    end,
    fg = "blue",
    bg = "mantle",
  },
}

local function is_valid_layout(windows)
  local win_type, win_id = windows[1], windows[2]
  if vim.islist(win_id) and win_type == t.COLUMN then win_id = win_id[1][2] end
  return supported_win_types[win_type] and type(win_id) == "number", win_id
end

local function is_offset(windows, side)
  local wins = { windows[1] }
  if #windows > 1 then wins = windows end

  local valid_ids = {}

  for idx, win in ipairs(wins) do
    local valid_layout, win_id = is_valid_layout(win)
    if valid_layout then
      local buf = vim.api.nvim_win_get_buf(win_id)
      local win_side = idx == 1 and "left" or "right"

      local valid = vim.tbl_contains(vim.tbl_keys(SIDEBAR_TITLE), vim.bo[buf].filetype) and side == win_side

      if valid then table.insert(valid_ids, win_id) end
    end
  end

  if vim.tbl_isempty(valid_ids) then return false, nil end
  return true, valid_ids
end

local function iterate_col_layout(layout) return layout[1] == t.COLUMN and iterate_col_layout(layout[2][1]) or layout end

---@param side "left"|"right"
return function(side)
  return {
    condition = function(self)
      local layout = iterate_col_layout(vim.fn.winlayout())
      if layout[1] ~= t.ROW then return false end

      local is_valid, win_ids = is_offset(layout[2], side)
      if not is_valid or not win_ids then return false end

      self.win_ids = win_ids
      return true
    end,
    init = function(self)
      local children = {}

      for _, win_id in ipairs(self.win_ids) do
        local buf = vim.api.nvim_win_get_buf(win_id)
        local ft = vim.bo[buf].filetype

        local title_opts = SIDEBAR_TITLE[ft] or {}
        local title = type(title_opts.name) == "function" and title_opts.name(win_id) or ""
        local width = vim.api.nvim_win_get_width(win_id)
        local title_width = vim.api.nvim_strwidth(title)
        local left_pad = math.floor((width - title_width) / 2)
        local right_pad = width - left_pad - title_width

        local child = {
          provider = (" "):rep(left_pad) .. title .. (" "):rep(right_pad),
          hl = { fg = title_opts.fg or "blue", bg = title_opts.bg or "base", bold = true },
        }

        table.insert(children, { provider = "│", hl = { fg = "crust", bg = "base" } })
        table.insert(children, child)
      end

      self.child = self:new(children, 1)
    end,
    provider = function(self) return self.child:eval() end,
  }
end
