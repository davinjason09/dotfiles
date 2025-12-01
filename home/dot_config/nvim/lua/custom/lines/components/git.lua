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

M.Status = {
  condition = C.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0
      or self.status_dict.removed ~= 0
      or self.status_dict.changed ~= 0
  end,
  update = {
    "User",
    pattern = "GitSigns*",
    callback = function()
      local what = vim.o.showtabline ~= 2 and "stl" or "tab"
      U.redraw(what)
    end,
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and (" " .. count .. " ")
    end,
    hl = { fg = "green" },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and (" " .. count .. " ")
    end,
    hl = { fg = "yellow" },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and (" " .. count .. " ")
    end,
    hl = { fg = "red" },
  },
}

return M
