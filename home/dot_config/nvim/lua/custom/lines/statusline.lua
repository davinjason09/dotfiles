local Comp = require("custom.lines.components")
local U = require("custom.lines.utils")
local Common = require("custom.lines.common").components
local mode_icons = Defaults.icons.modes
local cond = require("heirline.conditions")

local SpecialStatusLine = {
  condition = function()
    return cond.buffer_matches({
      buftype = { "quickfix" },
      filetype = { "lazy", "mason", "snacks_picker*", "minifiles*" },
    })
  end,

  Comp.Special.Mode,
  Comp.Special.Info,
  Common.Align,
  { condition = function() return vim.bo.buftype == "quickfix" end, Comp.Ruler },
  {
    condition = function() return vim.bo.buftype ~= "quickfix" end,
    Common.Separator2({
      icon = "",
      hl = function(self) return { fg = self:mode_color() } end,
      update = { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
    }),
  },
  Comp.Clock,
}

local TerminalStatusLine = {
  condition = function() return cond.buffer_matches({ buftype = { "terminal" } }) end,

  static = {
    -- stylua: ignore
    mode_map = {
      ["t"]     = { "TERMINAL",  "sky" },
      ["nt"]    = { "NTERMINAL", "yellow" },
      ["ntT"]   = { "NTERMINAL", "yellow" },
      ["no"]    = { "O-PENDING", "blue" },
      ["nov"]   = { "O-PENDING", "blue" },
      ["noV"]   = { "O-PENDING", "blue" },
      ["no\22"] = { "O-PENDING", "blue" },
      ["v"]     = { "VISUAL",    "mauve" },
      ["vs"]    = { "VISUAL",    "mauve" },
      ["V"]     = { "V-LINE",    "mauve" },
      ["Vs"]    = { "V-LINE",    "mauve" },
      ["\22"]   = { "V-BLOCK",   "mauve" },
      ["\22s"]  = { "V-BLOCK",   "mauve" },
      ["c"]     = { "COMMAND",   "peach" },
      ["cv"]    = { "COMMAND",   "peach" },
      ["ce"]    = { "COMMAND",   "peach" },
      ["cr"]    = { "COMMAND",   "peach" },
    },
    mode_name = function(self)
      local mode = vim.fn.mode(1) or "t"
      return self.mode_map[mode][1] or "TERMINAL"
    end,
    mode_color = function(self)
      local mode = vim.fn.mode(1) or "t"
      return self.mode_map[mode][2] or "sky"
    end,
  },
  Comp.Terminal.Mode,
  Comp.Terminal.CWD,
  {
    condition = function() return not (vim.b.term_title or ""):find("term://") end,
    Common.Separator2({ icon = "", hl = { fg = "surface0" } }),
  },
  Common.Align,
  Comp.Terminal.Command,
  Comp.Terminal.Name,
  Common.Space(),
  Common.Separator2({
    icon = "",
    hl = function(self) return { fg = self:mode_color() } end,
    update = { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
  }),
  Comp.Clock,
}

local MainStatusLine = {
  Comp.ViMode,
  Comp.Git.Branch,
  Comp.FileName,
  Common.Align,
  {
    condition = function() return vim.o.showtabline ~= 2 end,
    Comp.Macro,
    Comp.Git.Status,
  },
  Comp.Lazy,
  Comp.AI.Copilot,
  Comp.Lsp,
  Comp.Ruler,
  Comp.Clock,
}

return {
  hl = { bg = "crust" },
  static = {
    -- stylua: ignore
    mode_colors = {
      n       = { "blue",  mode_icons.Normal },
      i       = { "green", mode_icons.Insert },
      v       = { "mauve", mode_icons.Visual },
      V       = { "mauve", mode_icons.Visual },
      ["\22"] = { "mauve", mode_icons.Visual },
      c       = { "peach", mode_icons.Command },
      s       = { "mauve", mode_icons.Select },
      S       = { "mauve", mode_icons.Select },
      ["\19"] = { "mauve", mode_icons.Select },
      R       = { "red",   mode_icons.Replace },
      r       = { "red",   mode_icons.Replace },
      ["!"]   = { "peach", mode_icons.Shell },
      t       = { "sky",   mode_icons.Terminal },
    },
    mode_color = function(self) return self.mode_colors[vim.fn.mode()][1] end,
    mode_icon = function(self) return self.mode_colors[vim.fn.mode()][2] end,
  },

  fallthrough = false,
  SpecialStatusLine,
  TerminalStatusLine,
  MainStatusLine,
}
