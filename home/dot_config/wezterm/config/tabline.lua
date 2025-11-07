local wez = require("wezterm") ---@type Wezterm
local tabline = wez.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

local M = {}

local icon_map = {
  default = { icon = "" },
  nvim = {
    icon = { "", color = "#a6e3a1" },
  },
  lg = {
    icon = { "󰒲", color = "#fab387" },
    name = "lazygit",
  },
  nu = {
    icon = { "", color = "#a6e3a1" },
  },
}

local function get_icon_and_name(title)
  local split = {}
  for i in title:gmatch("([^-]+)") do
    table.insert(split, i)
  end

  local process_name = split[#split]:match("^%s*(.-)%s*$")
  if process_name:find("") then
    process_name = "nvim"
  elseif process_name:find("") then
    process_name = "nu"
  end

  local map = icon_map[process_name] or icon_map["default"]
  process_name = map.name or process_name

  return map.icon, process_name
end

---@param window Window
local function pad(window)
  local tabs = window:mux_window():tabs()
  local mid_width = 0

  for idx, tab in ipairs(tabs) do
    local pane_title = tab:active_pane():get_title()
    local icon, title = get_icon_and_name(pane_title)
    local icon_len = type(icon) == "table" and #icon[1] or #icon

    mid_width = mid_width + math.floor(math.log(idx, 10)) + 1
    mid_width = mid_width + 2 + icon_len + #title + 1
  end

  local tab_width = window:active_tab():get_size().cols
  local max_left = tab_width / 2 - mid_width / 2 - 10

  return string.rep(" ", math.floor(max_left))
end

---@param tab_info TabInformation
local function tab_title(tab_info)
  local title = tab_info.active_pane.title
  local icon, process_name = get_icon_and_name(title)

  local fmt = {}
  if type(icon) == "table" then
    if icon.color then table.insert(fmt, { Foreground = { Color = icon.color } }) end
    table.insert(fmt, { Text = icon[1] .. " " })
  else
    table.insert(fmt, { Text = icon .. " " })
  end

  table.insert(fmt, { Foreground = { Color = "#89B4FA" } })
  table.insert(fmt, { Text = process_name })
  table.insert(fmt, "ResetAttributes")

  return wez.format(fmt)
end

---@param is_active boolean
local function tab_section(is_active)
  return {
    { Attribute = { Intensity = is_active and "Bold" or "Half" } },
    { "index" },
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
      tabline_a = { { "mode", icon = "" } },
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
