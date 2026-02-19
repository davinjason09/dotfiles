local utils = require("utils")
local wez = require("wezterm") ---@type Wezterm
local tabline = wez.plugin.require("https://github.com/michaelbrusegard/tabline.wez") ---@type TablineWez

local M = {}

local icon_map = {
  default = {
    icon = "",
  },
  nvim = {
    icon = { "", color = "#A6E3A1" },
  },
  lg = {
    icon = { "󰒲", color = "#FAB387" },
    name = "lazygit",
  },
  nu = {
    icon = { "", color = "#A6E3A1" },
  },
  pwsh = {
    icon = { "", color = "#74C7EC" },
  },
}

---@param title string
---@param domain string
local function get_icon_and_name(title, domain)
  local split = {}
  for i in utils.gsplit(title, " - ", { plain = true }) do
    table.insert(split, i)
  end

  local process_name = split[#split]:match("^%s*(.-)%s*$")
  if process_name:find("") then
    process_name = "nvim"
  elseif process_name:find("") or process_name:match("[/~]") then
    process_name = utils.isWSL(domain) and "nu" or "pwsh"
  else
    process_name = utils.isWSL(domain) and "nu" or "pwsh"
  end

  local map = icon_map[process_name] or icon_map["default"]
  process_name = map.name or process_name

  return map.icon, process_name
end

local offset = 0

---@param window Window
local function pad(window)
  local tabs = window:mux_window():tabs()
  local mid_width = 0

  for idx, tab in ipairs(tabs) do
    local pane_title = tab:active_pane():get_title()
    local domain = tab:active_pane():get_domain_name()
    local icon, title = get_icon_and_name(pane_title, domain)
    local icon_len = type(icon) == "table" and #icon[1] or #icon

    mid_width = mid_width + math.floor(math.log(idx, 10)) + 1
    mid_width = mid_width + 2 + icon_len + #title + 1
  end

  local tab_width = window:active_tab():get_size().cols
  local max_left = tab_width / 2 - mid_width / 2 - offset

  return (" "):rep(math.floor(max_left))
end

---@param tab_info TabInformation
local function tab_icon(tab_info)
  local title = tab_info.active_pane.title
  local domain = wez.mux.get_pane(tab_info.active_pane.pane_id):get_domain_name()
  local icon, _ = get_icon_and_name(title, domain)

  local fmt = {}
  if type(icon) == "table" then
    if icon.color then table.insert(fmt, { Foreground = { Color = icon.color } }) end
    table.insert(fmt, { Text = icon[1] })
  else
    table.insert(fmt, { Text = icon })
  end

  return wez.format(fmt)
end

---@param tab_info TabInformation
local function tab_title(tab_info)
  local title = tab_info.active_pane.title
  local domain = wez.mux.get_pane(tab_info.active_pane.pane_id):get_domain_name()
  local _, process_name = get_icon_and_name(title, domain)

  if tab_info.is_active then
    return wez.format({
      { Foreground = { Color = "#89B4FA" } },
      { Text = process_name },
    })
  end

  return process_name
end

---@param is_active boolean
local function tab_section(is_active)
  return {
    { Attribute = { Intensity = is_active and "Bold" or "Half" } },
    { "index" },
    tab_icon,
    { Attribute = { Intensity = is_active and "Bold" or "Normal" } },
    " ",
    tab_title,
    " ",
  }
end

---@param config Config
function M.apply_to_config(config)
  local opts = {
    options = {
      theme = config.color_scheme,
      theme_overrides = {
        tab = { inactive_hover = { fg = "#F5C2E7", bg = "#1E1E2E" } },
      },
      section_separators = {
        left = "",
        right = "",
      },
      component_separators = {
        left = "",
        right = "",
      },
      tab_separators = {
        left = "",
        right = "",
      },
    },
    sections = {
      tabline_a = {
        {
          "mode",
          icon = "",
          fmt = function(str)
            offset = #str + 2 + 2
            return str
          end,
        },
      },
      tabline_b = {},
      tabline_c = { pad },
      tab_active = tab_section(true),
      tab_inactive = tab_section(false),
      tabline_x = {},
      tabline_y = { "battery" },
      tabline_z = { { "domain", domain_to_icon = { wsl = "" } } },
    },
  }

  tabline.setup(opts)
  tabline.apply_to_config(config)
  config.tab_bar_at_bottom = false
  config.hide_tab_bar_if_only_one_tab = true

  return config
end

return M
