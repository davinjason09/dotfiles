local M = {}

local Comp = require("custom.lines.common").components
local U = require("custom.lines.utils")

-- ╾╼ Helper functions ╾──────────────────────────────────────────────╼

---@param picker_list snacks.Picker[]
---@return snacks.Picker?
local function get_picker(picker_list)
  if not picker_list then return end

  local cur_win = vim.api.nvim_get_current_win()
  for _, pick in ipairs(picker_list) do
    for _, win in pairs(pick.layout.wins) do
      if win.win == cur_win then return pick end
    end
  end

  return nil
end

local function is_loclist() return vim.fn.getloclist(0, { filewinid = 0 }).filewinid ~= 0 end

local function qf_title()
  if is_loclist() then return vim.fn.getloclist(0, { title = 0 }).title end
  return vim.fn.getqflist({ title = 0 }).title
end

local function lazy_stats()
  local stats = require("lazy").stats()
  return ("Loaded: %s/%s"):format(stats.loaded, stats.count)
end

local function picker_stats()
  local filetype = vim.bo.filetype
  local picker = get_picker(Snacks.picker.get())
  if not picker then return "" end

  if filetype == "snacks_picker_list" then
    local count = picker:count()
    local cur_item = picker:current()

    if count == 0 then return "Empty" end
    -- TODO: handle this differently for specific picker
    if cur_item.file then return " " .. U.pretty_path(picker:dir(), "absolute") end

    return cur_item.idx .. " of " .. count .. " results"
  elseif filetype == "snacks_picker_input" then
    local input = picker.input and picker.input:get() or ""
    local count = input == "" and picker:count() or #picker:items()
    return input ~= "" and (" %s: %s results"):format(input, count) or (count .. " results")
  else
    if picker:current().file then
      local path = picker:current().file
      local filename = vim.fn.fnamemodify(path, ":t")
      local icon = Snacks.util.icon(filename, "file")
      return ("Preview: %s%s"):format(icon, U.pretty_path(path, "absolute"))
    else
      -- TODO: map picker source to the targetted field
      -- local picker_source = {
      --   ["Options"] = "text",
      --   ["Regisiters"] = "",
      -- }

      return "Preview: TODO"
    end
  end
end

local function minifiles_cwd()
  local MiniFiles = _G.MiniFiles or require("mini.files")

  if vim.bo.filetype:find("help") ~= nil then return " Help" end

  local cwd = (MiniFiles.get_fs_entry() or {}).path
  return " " .. U.pretty_path(vim.fn.fnamemodify(cwd, ":h"), "absolute")
end

local SpecialInfo = {
  lazy = lazy_stats,
  qf = qf_title,
  picker = picker_stats,
  minifiles = minifiles_cwd,
  ["minifiles-help"] = minifiles_cwd,
}

-- ╾╼ Components ╾────────────────────────────────────────────────────╼

M.Mode = {
  static = {
    filetype_map = {
      lazy = "󰒲 Lazy",
      minifiles = " MiniFiles",
      ["minifiles-help"] = " MiniFiles",
      qf = "󰅖 Quickfix List",
      snacks_picker = "🍿%s",
    },
  },
  init = U.update_events({ "BufEnter" }),
  update = { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
  provider = function(self)
    local ft = vim.bo.filetype
    local is_picker = false

    if ft:find("snacks_picker") ~= nil then
      ft = "snacks_picker"
      is_picker = true
    end

    local title = self.filetype_map[ft]

    if ft == "qf" and is_loclist() then return "  Location List " end
    if not is_picker then return " " .. title .. " " end

    local picker = get_picker(Snacks.picker.get())
    local is_explorer = ft == "snacks_picker_list" and picker.title == "Explorer"

    local name = is_explorer and "" or (" (%s)"):format(picker.title)
    local picker_type = is_explorer and "Explorer" or "Picker"

    return (" %s%s "):format(title:format(picker_type), name)
  end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color(), bold = true } end,
  Comp.Separator({
    icon = "",
    hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
  }),
}

M.Info = {
  init = U.update_events({
    { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
  }),
  provider = function()
    local filetype = vim.bo.filetype
    if filetype:match("snacks_picker*") then return (" %s "):format(SpecialInfo.picker()) end

    return (" %s "):format(SpecialInfo[filetype]())
  end,
  hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
  Comp.Separator({
    icon = "",
    hl = { fg = "surface0", bg = "crust" },
  }),
}

return M
