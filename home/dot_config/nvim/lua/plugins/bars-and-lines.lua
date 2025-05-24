return {
  {
    "rebelot/heirline.nvim",
    event = "VeryLazy",
    config = function()
      local cond = require("heirline.conditions")
      local utils = require("heirline.utils")
      local C = require("plugins.heirline.components")
      local U = require("plugins.heirline.helpers")

      local colors = require("catppuccin.palettes").get_palette("mocha")
      colors = vim.tbl_extend("force", colors, {
        MiniIconsRed = utils.get_highlight("MiniIconsRed").fg,
        MiniIconsBlue = utils.get_highlight("MiniIconsBlue").fg,
        MiniIconsCyan = utils.get_highlight("MiniIconsCyan").fg,
        MiniIconsGrey = utils.get_highlight("MiniIconsGrey").fg,
        MiniIconsAzure = utils.get_highlight("MiniIconsAzure").fg,
        MiniIconsGreen = utils.get_highlight("MiniIconsGreen").fg,
        MiniIconsOrange = utils.get_highlight("MiniIconsOrange").fg,
        MiniIconsPurple = utils.get_highlight("MiniIconsPurple").fg,
        MiniIconsYellow = utils.get_highlight("MiniIconsYellow").fg,
      })

      local SpecialStatusLine = {
        condition = function()
          return cond.buffer_matches({
            buftype = { "quickfix" },
            filetype = { "lazy", "mason", "snacks_picker*", "minifiles*" },
          })
        end,
        { condition = cond.is_active, C.SpecialMode },
        -- C.SpecialMode,
        C.SpecialInfo,
        C.Align,
        { condition = function() return vim.bo.filetype == "qf" end, C.Ruler },
        {
          condition = function() return vim.bo.buftype ~= "quickfix" end,
          C.Separator(
            "",
            function(self) return { fg = self:mode_color() } end,
            { "User", pattern = "ForceRedraw", callback = U.redraw() }
          ),
        },
        C.Clock,
      }

      local TerminalStatusLine = {
        condition = function() return cond.buffer_matches({ buftype = { "terminal" } }) end,
        static = {
          -- stylua: ignore
          mode_map = {
            ["t"]     = { "TERMINAL", "sky" },
            ["nt"]    = { "NTERMINAL", "yellow" },
            ["ntT"]   = { "NTERMINAL", "yellow" },
            ["no"]    = { "O-PENDING", "blue" },
            ["nov"]   = { "O-PENDING", "blue" },
            ["noV"]   = { "O-PENDING", "blue" },
            ["no\22"] = { "O-PENDING", "blue" },
            ["v"]     = { "VISUAL", "mauve" },
            ["vs"]    = { "VISUAL", "mauve" },
            ["V"]     = { "V-LINE", "mauve" },
            ["Vs"]    = { "V-LINE", "mauve" },
            ["\22"]   = { "V-BLOCK", "mauve" },
            ["\22s"]  = { "V-BLOCK", "mauve" },
          },
          mode_color = function(self)
            local mode = cond.is_active() and vim.fn.mode(1)
            return self.mode_map[mode] and self.mode_map[mode][2] or "sky"
          end,
          mode_name = function(self)
            local mode = cond.is_active() and vim.fn.mode(1)
            return self.mode_map[mode] and self.mode_map[mode][1] or "TERMINAL"
          end,
        },
        { condition = cond.is_active, C.TerminalMode },
        C.TermCwd,
        {
          condition = function() return not vim.b.term_title:find("term://") end,
          C.Separator("", { fg = "surface0" }),
        },
        C.Align,
        C.TermCommand,
        C.FileNameBlock,
        C.Space(),
        C.Separator(
          "",
          function(self) return { fg = self:mode_color() } end,
          { "User", pattern = "ForceRedraw", callback = U.redraw() }
        ),
        C.Clock,
      }

      local MainStatusLine = {
        C.ViMode,
        C.GitBranch,
        C.FileNameBlock,
        C.Align,
        C.Keystroke,
        C.MacroRecording,
        C.LazyUpdate,
        C.Copilot,
        C.ActiveLSP,
        C.Ruler,
        C.Clock,
      }

      local statusline = {
        hl = { bg = "mantle" },
        static = {
          -- stylua: ignore
          mode_colors = {
            n       = { "blue",  Defaults.icons.modes.Normal },
            i       = { "green", Defaults.icons.modes.Insert },
            v       = { "mauve", Defaults.icons.modes.Visual },
            V       = { "mauve", Defaults.icons.modes.Visual },
            ["\22"] = { "mauve", Defaults.icons.modes.Visual },
            c       = { "peach", Defaults.icons.modes.Command },
            s       = { "mauve", Defaults.icons.modes.Select },
            S       = { "mauve", Defaults.icons.modes.Select },
            ["\19"] = { "mauve", Defaults.icons.modes.Select },
            R       = { "red",   Defaults.icons.modes.Replace },
            r       = { "red",   Defaults.icons.modes.Replace },
            ["!"]   = { "peach", Defaults.icons.modes.Shell },
            t       = { "sky",   Defaults.icons.modes.Terminal },
          },
          mode_color = function(self)
            local mode = cond.is_active() and vim.fn.mode() or "n"
            return self.mode_colors[mode][1]
          end,
          mode_icon = function(self)
            local mode = cond.is_active() and vim.fn.mode() or "n"
            return self.mode_colors[mode][2]
          end,
        },

        fallthrough = false,
        SpecialStatusLine,
        TerminalStatusLine,
        MainStatusLine,
      }

      local uv = vim.uv or vim.loop
      uv.new_timer():start(
        (60 - tonumber(os.date("%S"))) * 1000,
        60000,
        vim.schedule_wrap(
          function()
            vim.api.nvim_exec_autocmds("User", { pattern = "UpdateTime", modeline = false })
          end
        )
      )

      require("heirline").setup({
        statusline = statusline,
        opts = { colors = colors },
      })
    end,
  },
}
