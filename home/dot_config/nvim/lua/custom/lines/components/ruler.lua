local Comp = require("custom.lines.common").components
local U = require("custom.lines.utils")

return {
  update = { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
  Comp.Separator2({ icon = "", hl = { fg = "surface0", bg = "crust" } }),
  {
    provider = "  %l  %c ",
    hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
  },
  Comp.Separator2({
    icon = "",
    hl = function(self) return { fg = "surface0", bg = self:mode_color() } end,
  }),
}
