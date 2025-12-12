local Comp = require("custom.lines.components")
local Common = require("custom.lines.common").components
local utils = require("heirline.utils")

return {
  Comp.Offset("left"),
  Comp.Misc.Tabline.Left,
  Comp.Macro,
  utils.make_buflist(
    Comp.Buffer,
    { provider = " ", hl = { fg = "overlay2" } },
    { provider = " ", hl = { fg = "overlay2" } },
    function() return require("custom.lines")._buflist_cache end,
    false
  ),
  Common.Align,
  Comp.Git.Status,
  Comp.TabPage,
  Comp.Misc.Tabline.Right,
  Comp.Offset("right"),
}
