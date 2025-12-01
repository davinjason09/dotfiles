local Comp = require("custom.lines.common").components
local C = require("heirline.conditions")
local U = require("custom.lines.utils")

return {
  static = {
    -- stylua: ignore
    mode_map = {
      ["n"]     = "NORMAL",
      ["niI"]   = "NORMAL",
      ["niR"]   = "NORMAL",
      ["niV"]   = "NORMAL",
      ["no"]    = "O-PENDING",
      ["nov"]   = "O-PENDING",
      ["noV"]   = "O-PENDING",
      ["no\22"] = "O-PENDING",

      ["v"]     = "VISUAL",
      ["vs"]    = "VISUAL",
      ["V"]     = "V-LINE",
      ["Vs"]    = "V-LINE",
      ["\22"]   = "V-BLOCK",
      ["\22s"]  = "V-BLOCK",

      ["s"]     = "SELECT",
      ["S"]     = "S-LINE",
      ["\19"]   = "S-BLOCK",

      ["i"]     = "INSERT",
      ["ic"]    = "INSERT",
      ["ix"]    = "INSERT",

      ["R"]     = "REPLACE",
      ["Rc"]    = "REPLACE",
      ["Rx"]    = "REPLACE",
      ["Rv"]    = "V-REPLACE",
      ["Rvc"]   = "V-REPLACE",
      ["Rvx"]   = "V-REPLACE",

      ["r"]     = "PROMPT",
      ["rm"]    = "MORE",
      ["r?"]    = "CONFIRM",
      ["x"]     = "CONFIRM",

      ["c"]     = "COMMAND",
      ["cv"]    = "COMMAND",
      ["ce"]    = "COMMAND",
      ["cr"]    = "COMMAND",
      ["!"]     = "SHELL",

      ["t"]     = "TERMINAL",
      ["nt"]    = "NTERMINAL",
      ["ntT"]   = "NTERMINAL",
    },
  },
  init = U.update_events({ "BufEnter" }),
  update = {
    "ModeChanged",
    "User",
    pattern = { "*:*", "GitSigns*" },
    callback = function() U.redraw() end,
  },
  provider = function(self)
    return (" %s %s "):format(self:mode_icon(), self.mode_map[vim.fn.mode(1)])
  end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color(), bold = true } end,
  Comp.Separator2({
    icon = "",
    hl = function(self)
      return { fg = self:mode_color(), bg = C.is_git_repo() and "surface0" or "crust" }
    end,
  }),
}
