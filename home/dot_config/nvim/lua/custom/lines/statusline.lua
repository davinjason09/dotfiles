local Comp = require("custom.lines.components")
local U = require("custom.lines.utils")
local Common = require("custom.lines.common").components
local mode_icons = Defaults.icons.modes
local cond = require("heirline.conditions")

local SpecialStatusLine = {
  condition = function()
    return cond.buffer_matches({
      buftype = { "quickfix" },
      filetype = { "lazy", "snacks_picker*", "minifiles*" },
    })
  end,

  Comp.Special.Mode,
  Comp.Special.Info,
  Common.Align,
  { condition = function() return vim.bo.buftype == "quickfix" end, Comp.Ruler },
  {
    condition = function() return vim.bo.buftype ~= "quickfix" end,
    Common.Separator({
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
      ["t"]     = { name = "TERMINAL",  color = "sky" },
      ["nt"]    = { name = "NTERMINAL", color = "yellow" },
      ["ntT"]   = { name = "NTERMINAL", color = "yellow" },
      ["no"]    = { name = "O-PENDING", color = "blue" },
      ["nov"]   = { name = "O-PENDING", color = "blue" },
      ["noV"]   = { name = "O-PENDING", color = "blue" },
      ["no\22"] = { name = "O-PENDING", color = "blue" },
      ["v"]     = { name = "VISUAL",    color = "mauve" },
      ["vs"]    = { name = "VISUAL",    color = "mauve" },
      ["V"]     = { name = "V-LINE",    color = "mauve" },
      ["Vs"]    = { name = "V-LINE",    color = "mauve" },
      ["\22"]   = { name = "V-BLOCK",   color = "mauve" },
      ["\22s"]  = { name = "V-BLOCK",   color = "mauve" },
      ["c"]     = { name = "COMMAND",   color = "peach" },
      ["cv"]    = { name = "COMMAND",   color = "peach" },
      ["ce"]    = { name = "COMMAND",   color = "peach" },
      ["cr"]    = { name = "COMMAND",   color = "peach" },
    },
    get_map_value = function(self, field, default)
      local res = self.mode_map[vim.fn.mode(1)] or nil
      return res and res[field] or default
    end,
    mode_name = function(self) return self:get_map_value("name", "TERMINAL") end,
    mode_color = function(self) return self:get_map_value("color", "sky") end,
  },
  Comp.Terminal.Mode,
  Comp.Terminal.CWD,
  {
    condition = function() return not (vim.b.term_title or ""):find("term://") end,
    Common.Separator({ icon = "", hl = { fg = "surface0" } }),
  },
  Common.Align,
  Comp.Terminal.Command,
  Comp.Terminal.Name,
  Common.Space(),
  Common.Separator({
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
  condition = function() return not cond.buffer_matches({ filetype = { "snacks_dashboard" } }) end,
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

    icon_to_hl = {
      [""] = "red",
      [""] = "teal",
      [""] = "sky",
      [""] = "yellow",
    },
  },

  fallthrough = false,
  SpecialStatusLine,
  TerminalStatusLine,
  MainStatusLine,
}
