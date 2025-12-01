local M = {}

local Comp = require("custom.lines.common").components
local C = require("heirline.conditions")
local U = require("custom.lines.utils")

M.Branch = {
  condition = C.is_git_repo,
  init = U.update_events({ "BufEnter" }),
  update = {
    "ModeChanged",
    "User",
    pattern = { "*:*", "GitSigns*" },
    callback = function() U.redraw() end,
  },
  provider = function()
    local branch = vim.b.gitsigns_head or ""
    return ("  %s "):format(branch ~= "" and branch or "main")
  end,
  hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
  Comp.Separator2({ icon = "", hl = { fg = "surface0", bg = "crust" } }),
}

return M
