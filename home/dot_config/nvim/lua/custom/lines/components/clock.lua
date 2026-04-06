local U = require("custom.lines.utils")

return {
  static = {
    clock_icons = { "󱑋", "󱑌", "󱑍", "󱑎", "󱑏", "󱑐", "󱑑", "󱑒", "󱑓", "󱑔", "󱑕", "󱑖" },
  },
  update = { "ModeChanged", "User", pattern = { "*:*", "UpdateTime" }, callback = function() U.redraw() end },
  provider = function(self)
    local hour = os.date("%I")
    local icon = self.clock_icons[tonumber(hour)]

    return (" %s %s "):format(icon, os.date("%H:%M"))
  end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color(), bold = true } end,
}
