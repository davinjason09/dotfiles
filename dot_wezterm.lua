local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}
local colors = {}

config.font_size = 7.25
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.command_palette_font_size = 7.25
config.char_select_font_size = 7.25

config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

config.color_scheme = 'Catppuccin Mocha'
config.custom_block_glyphs = false
config.anti_alias_custom_block_glyphs = false
config.allow_square_glyphs_to_overflow_width = 'Never'
config.front_end = 'WebGpu'

config.initial_cols = 180
config.initial_rows = 45

config.default_prog = { 'pwsh.exe', '-NoLogo' }

config.launch_menu = {
  { label = 'Powershell',         args = { 'pwsh.exe', '-NoLogo' }, },
  { label = 'Windows Powershell', args = { 'powershell.exe', '-NoLogo'}, },
  { label = 'CMD',                args = { 'cmd.exe' }, }
}

config.window_frame = {
	font = wezterm.font('JetBrainsMono Nerd Font', { weight='Bold', stretch='Normal', style='Normal' }),
	font_size = 8.0,
}

colors = {
	split = '#42675A'
}

-- Keys
config.disable_default_key_bindings = true
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 3000}
config.keys = {
  -- Activate Tabs
  { key = 'Tab',          mods = 'CTRL',        action = act.ActivateTabRelative(1) },
  { key = 'Tab',          mods = 'SHIFT|CTRL',  action = act.ActivateTabRelative(-1) },
  { key = '1',            mods = 'CTRL',        action = act.ActivateTab(0) },
  { key = '2',            mods = 'CTRL',        action = act.ActivateTab(1) },
  { key = '3',            mods = 'CTRL',        action = act.ActivateTab(2) },
  { key = '4',            mods = 'CTRL',        action = act.ActivateTab(3) },
  { key = '5',            mods = 'CTRL',        action = act.ActivateTab(4) },
  -- Split, Resize, and Activate Panes
  { key = "'",            mods = 'LEADER',      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = ';',            mods = 'LEADER',      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'h',            mods = 'LEADER',      action = act.ActivatePaneDirection("Left") },
  { key = 'h',            mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = 'j',            mods = 'LEADER',      action = act.ActivatePaneDirection("Down") },
  { key = 'j',            mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = 'k',            mods = 'LEADER',      action = act.ActivatePaneDirection("Up") },
  { key = 'k',            mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = 'l',            mods = 'LEADER',      action = act.ActivatePaneDirection("Right") },
  { key = 'l',            mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Right", 1 }) },
  -- { key = 'LeftArrow',    mods = 'LEADER',      action = act.ActivatePaneDirection("Left") },
  -- { key = 'LeftArrow',    mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Left", 1 }) },
  -- { key = 'DownArrow',    mods = 'LEADER',      action = act.ActivatePaneDirection("Down") },
  -- { key = 'DownArrow',    mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Down", 1 }) },
  -- { key = 'UpArrow',      mods = 'LEADER',      action = act.ActivatePaneDirection("Up") },
  -- { key = 'UpArrow',      mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Up", 1 }) },
  -- { key = 'RightArrow',   mods = 'LEADER',      action = act.ActivatePaneDirection("Right") },
  -- { key = 'RightArrow',   mods = 'SHIFT|CTRL',  action = act.AdjustPaneSize({ "Right", 1 }) },
  -- Adjust Font Size
  { key = '=',            mods = 'CTRL',        action = act.IncreaseFontSize },
  { key = '-',            mods = 'CTRL',        action = act.DecreaseFontSize },
  { key = '0',            mods = 'CTRL',        action = act.ResetFontSize }, 
  -- Other
  { key = 'F5',           mods = 'CTRL',        action = act.ReloadConfiguration },
  { key = 'C',            mods = 'SHIFT|CTRL',  action = act.CopyTo('Clipboard') },
  { key = 'f',            mods = 'CTRL',        action = act.Search('CurrentSelectionOrEmptyString') },
  { key = 'k',            mods = 'CTRL',        action = act.ClearScrollback('ScrollbackOnly') },
  { key = 'l',            mods = 'CTRL',        action = act.ShowDebugOverlay },
  { key = 'N',            mods = 'SHIFT|CTRL',  action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'p',            mods = 'CTRL',        action = act.ActivateCommandPalette },
  { key = 'q',            mods = 'LEADER',      action = act.CloseCurrentPane({ confirm = false}) },
  { key = 'T',            mods = 'SHIFT|CTRL',  action = act.ShowLauncher },
  { key = 'u',            mods = 'CTRL',        action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }) },
  { key = 'v',            mods = 'CTRL',        action = act.PasteFrom('Clipboard') },
  { key = 'X',            mods = 'SHIFT|CTRL',  action = act.ActivateCopyMode },
}

config.window_background_opacity = 0.8
config.win32_system_backdrop = 'Acrylic'
-- config.windows_decorations = 'RESIZE'
config.default_cursor_style = 'BlinkingBar'
config.hide_tab_bar_if_only_one_tab = true
config.colors = colors

-- Cursor
config.animation_fps = 1
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.cursor_blink_rate = 500 

config.inactive_pane_hsb = {
  hue = 0.9,
  saturation = 0.4,
  brightness = 0.2,
}

config.scrollback_lines = 10000
config.adjust_window_size_when_changing_font_size = false

config.window_close_confirmation = 'AlwaysPrompt'

return config