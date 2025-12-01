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
        -- vim.print({
        --   title = picker.title,
        --   box_win = picker.layout.box_wins[1].win,
        --   win_id = win_id,
        --   layout = vim.fn.winlayout(),
        -- })
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
  if #windows > 1 then wins[#wins + 1] = windows[#windows] end

  for idx, win in ipairs(wins) do
    local valid_layout, win_id = is_valid_layout(win)
    if valid_layout then
      local buf = vim.api.nvim_win_get_buf(win_id)
      local is_left = idx == 1
      local win_side = is_left and "left" or "right"
      local valid = vim.tbl_contains(vim.tbl_keys(SIDEBAR_TITLE), vim.bo[buf].filetype)
        and side == win_side

      if valid then return valid, win_id end
    end
  end

  return false, nil, nil
end

local function iterate_col_layout(layout)
  if layout[1] == t.COLUMN then
    return iterate_col_layout(layout[2][1])
  else
    return layout
  end
end

---@param side "left"|"right"
return function(side)
  return {
    condition = function(self)
      local layout = iterate_col_layout(vim.fn.winlayout())
      if layout[1] ~= t.ROW then return false end

      local is_valid, win_id = is_offset(layout[2], side)

      if not is_valid or not win_id then return false end

      self.winid = win_id

      local buf = vim.api.nvim_win_get_buf(win_id)
      local ft = vim.bo[buf].filetype
      local title = SIDEBAR_TITLE[ft] or {}

      if title.name ~= nil then
        self.title = title
        return true
      end
    end,
    provider = function(self)
      local title = self.title.name
      if type(title) == "function" then title = title(self.winid) end

      local width = vim.api.nvim_win_get_width(self.winid)
      local pad = math.ceil((width - vim.api.nvim_strwidth(title)) / 2)

      return string.rep(" ", pad) .. title .. string.rep(" ", pad)
    end,
    hl = function(self)
      return { fg = self.title.fg or "blue", bg = self.title.bg or "base", bold = true }
    end,
  }
end
