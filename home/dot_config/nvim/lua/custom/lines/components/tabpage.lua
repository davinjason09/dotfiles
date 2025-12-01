local utils = require("heirline.utils")

local Tabpage = {
  {
    provider = function(self) return " %" .. self.tabnr .. "T" .. self.tabnr .. " " end,
    hl = { bold = true },
  },
  hl = function(self) return self.is_active and "TabLine" or "TabLineSel" end,
  update = { "TabNew", "TabClosed", "TabEnter", "TabLeave", "WinNew", "WinClosed" },
}

local TabpageCloseButton = {
  provider = " %999X  %X",
  hl = "TabLine",
}

return {
  condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
  utils.make_tablist(Tabpage),
  TabpageCloseButton,
}
