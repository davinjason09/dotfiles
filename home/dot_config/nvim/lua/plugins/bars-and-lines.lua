return {
  {
    "akinsho/bufferline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    -- stylua: ignore
    keys = {
      { "<leader>bp", "<CMD>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<CMD>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers", },
      { "<leader>br", "<CMD>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<CMD>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "H", "<CMD>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
      { "L", "<CMD>BufferLineCycleNext<CR>", desc = "Next Buffer" },
      { "[b", "<CMD>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
      { "]b", "<CMD>BufferLineCycleNext<CR>", desc = "Next Buffer" },
      { "[B", "<CMD>BufferLineMovePrev<CR>", desc = "Move buffer prev" },
      { "]B", "<CMD>BufferLineMoveNext<CR>", desc = "Move buffer next" },
    },
    opts = {
      options = {
        close_command = function(buf) Snacks.bufdelete(buf) end,
        right_mouse_command = function(buf) Snacks.bufdelete(buf) end,
        get_element_icon = function(opts)
          return Snacks.util.icon(opts.path, opts.directory and "directory" or "file")
        end,
        separator_style = "slope",
        indicator = { style = "underline" },
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icon = Defaults.icons.diagnostics
          local ret = (diag.error and icon.ERROR or "") .. (diag.warning and icon.WARN or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "snacks_layout_box",
            text = "󰙅 File Explorer",
            highlight = "SnacksExplorerTitle",
            text_align = "center",
          },
        },
        custom_areas = {
          left = function()
            local colors = Defaults.palette
            return {
              { text = "  ", fg = colors.crust, bg = colors.lavender },
              { text = " ", fg = colors.lavender, bg = colors.crust },
            }
          end,
          right = function()
            local colors = Defaults.palette
            return {
              { text = " ", fg = colors.lavender, bg = colors.crust },
              { text = " 󰮯  ", fg = colors.crust, bg = colors.lavender, bold = true },
            }
          end,
        },
      },
    },
  },
  {
    "b0o/incline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
        zindex = 100,
      },
      render = function(props)
        local C = require("plugins.incline.components")
        local mode = vim.fn.mode()
        local palette = Defaults.palette
        local file_info = C.file(props)

        return {
          { " ▓", guifg = C.get_mode_color(mode, props.focused) },
          {
            { C.get_diagnostics(props) },
            { C.get_diff(props) },
            { (" %s"):format(file_info.icon[1]), guifg = file_info.icon.guifg },
            {
              ("%s "):format(file_info.name[1]),
              guifg = file_info.name.guifg,
              gui = file_info.modified.gui,
            },
            guibg = palette.mantle,
          },
          { "▓", guifg = C.get_mode_color(mode, props.focused) },
        }
      end,
    },
  },
  {
    "rebelot/heirline.nvim",
    event = "VeryLazy",
    config = function()
      local cond = require("heirline.conditions")
      local C = require("plugins.heirline.components")
      local U = require("plugins.heirline.helpers")
      local colors = require("catppuccin.palettes").get_palette("mocha")
      local icons = Defaults.icons.modes

      local SpecialStatusLine = {
        condition = function()
          return cond.buffer_matches({
            buftype = { "quickfix" },
            filetype = { "lazy", "mason", "snacks_picker*", "minifiles*" },
          })
        end,
        { condition = cond.is_active, C.SpecialMode },
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
          condition = function() return not (vim.b.term_title or ""):find("term://") end,
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
        C.MacroRecording,
        C.LazyUpdate,
        C.Copilot,
        C.ActiveLSP,
        C.Ruler,
        C.Clock,
      }

      local statusline = {
        hl = { bg = "crust" },
        static = {
          -- stylua: ignore
          mode_colors = {
            n       = { "blue",  icons.Normal },
            i       = { "green", icons.Insert },
            v       = { "mauve", icons.Visual },
            V       = { "mauve", icons.Visual },
            ["\22"] = { "mauve", icons.Visual },
            c       = { "peach", icons.Command },
            s       = { "mauve", icons.Select },
            S       = { "mauve", icons.Select },
            ["\19"] = { "mauve", icons.Select },
            R       = { "red",   icons.Replace },
            r       = { "red",   icons.Replace },
            ["!"]   = { "peach", icons.Shell },
            t       = { "sky",   icons.Terminal },
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
