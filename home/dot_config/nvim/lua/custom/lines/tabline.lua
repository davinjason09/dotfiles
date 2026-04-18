local Comp = require("custom.lines.components")
local Common = require("custom.lines.common").components
local utils = require("heirline.utils")

return {
  static = {
    icon_to_hl = { [""] = "red", [""] = "teal", [""] = "sky", [""] = "yellow" },
  },
  Comp.Offset("left"),
  Comp.Misc.Tabline.Left,
  Comp.Macro,
  utils.make_buflist(
    Comp.Buffer,
    { provider = " ", hl = { fg = "overlay2" } },
    { provider = " ", hl = { fg = "overlay2" } },
    function() return require("custom.lines.utils").State.buflist_cache end,
    false
  ),
  Common.Align,
  Comp.Git.Status,
  Comp.TabPage,
  Comp.Misc.Tabline.Right,
  Comp.Offset("right"),
}
