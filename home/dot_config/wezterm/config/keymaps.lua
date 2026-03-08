local wez = require("wezterm") ---@type Wezterm
local act = wez.action

local mod = {
  CTRL = "CTRL",
  CSHIFT = "CTRL|SHIFT",
  CALT = "CTRL|ALT",
  CSALT = "CTRL|SHIFT|ALT",
  LEADER = "LEADER",
}

-- stylua: ignore
local keys = {
  -- Activate Tabs
  { key = "Tab", mods = mod.CTRL,   action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = mod.CSHIFT, action = act.ActivateTabRelative(-1) },
  { key = "1",   mods = mod.CTRL,   action = act.ActivateTab(0) },
  { key = "2",   mods = mod.CTRL,   action = act.ActivateTab(1) },
  { key = "3",   mods = mod.CTRL,   action = act.ActivateTab(2) },
  { key = "4",   mods = mod.CTRL,   action = act.ActivateTab(3) },
  { key = "5",   mods = mod.CTRL,   action = act.ActivateTab(4) },

  -- Split, Resize, Rotate, and Activate Panes
  { key = "-",          mods = mod.LEADER, action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "\\",         mods = mod.LEADER, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "h",          mods = mod.LEADER, action = act.ActivatePaneDirection("Left") },
  { key = "h",          mods = mod.CSHIFT, action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "j",          mods = mod.LEADER, action = act.ActivatePaneDirection("Down") },
  { key = "j",          mods = mod.CSHIFT, action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = "k",          mods = mod.LEADER, action = act.ActivatePaneDirection("Up") },
  { key = "k",          mods = mod.CSHIFT, action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "l",          mods = mod.LEADER, action = act.ActivatePaneDirection("Right") },
  { key = "l",          mods = mod.CSHIFT, action = act.AdjustPaneSize({ "Right", 1 }) },
  { key = "LeftArrow",  mods = mod.LEADER, action = act.ActivatePaneDirection("Left") },
  { key = "LeftArrow",  mods = mod.CALT,   action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "DownArrow",  mods = mod.LEADER, action = act.ActivatePaneDirection("Down") },
  { key = "DownArrow",  mods = mod.CALT,   action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = "UpArrow",    mods = mod.LEADER, action = act.ActivatePaneDirection("Up") },
  { key = "UpArrow",    mods = mod.CALT,   action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "RightArrow", mods = mod.LEADER, action = act.ActivatePaneDirection("Right") },
  { key = "RightArrow", mods = mod.CALT,   action = act.AdjustPaneSize({ "Right", 1 }) },
  { key = "0",          mods = mod.LEADER, action = act.PaneSelect({ mode = "SwapWithActive", alphabet = "1234567890" }) },
  { key = "r",          mods = mod.LEADER, action = act.RotatePanes("Clockwise") },
  { key = "R",          mods = mod.LEADER, action = act.RotatePanes("CounterClockwise") },

  -- Adjust Font Size
  { key = "=", mods = mod.CTRL, action = act.IncreaseFontSize },
  { key = "-", mods = mod.CTRL, action = act.DecreaseFontSize },
  { key = "0", mods = mod.CTRL, action = act.ResetFontSize },

  -- Copy Mode
  { key = "x", mods = mod.CSHIFT, action = act.ActivateCopyMode },
  { key = "c", mods = mod.CSHIFT, action = act.CopyTo("Clipboard") },
  { key = "v", mods = mod.CSHIFT, action = act.PasteFrom("Clipboard") },

  -- Other
  { key = "F5", mods = mod.CTRL,   action = act.ReloadConfiguration },
  { key = "f",  mods = mod.CSHIFT, action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "k",  mods = mod.LEADER, action = act.ClearScrollback("ScrollbackOnly") },
  { key = "l",  mods = mod.LEADER, action = act.ShowDebugOverlay },
  { key = "n",  mods = mod.CSHIFT, action = act.SpawnTab("CurrentPaneDomain") },
  { key = "p",  mods = mod.CSHIFT, action = act.ActivateCommandPalette },
  { key = "q",  mods = mod.LEADER, action = act.CloseCurrentPane({ confirm = false }) },
  { key = "t",  mods = mod.CSHIFT, action = act.ShowLauncher },
  { key = "u",  mods = mod.CSHIFT, action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }) },
  { key = "/",  mods = mod.LEADER, action = act.Search({ CaseInSensitiveString = "" }) },
}

return {
  disable_default_key_bindings = true,
  leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1500 },
  keys = keys,
}
