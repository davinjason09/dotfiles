---Add powerline symbols to the title of popups
---@alias title_opts { msg: string, views?: string, kind?: string }
---@param opts title_opts
local function title(opts)
  opts.views = opts.views or "cmdline_popup"

  local powerline_hl = ""
  if opts.views == "confirm" then
    powerline_hl = "NoiceConfirmBorder"
  elseif opts.kind then
    powerline_hl = "NoiceCmdlinePopupBorder" .. opts.kind:sub(1, 1):upper() .. opts.kind:sub(2)
  end

  return {
    { "", powerline_hl },
    { opts.msg },
    { "", powerline_hl },
  }
end

local nvim_version = ("  v%s "):format(Utils.nvim_version())
local lua_version = ("  %s "):format(_VERSION)

return {
  { "MunifTanjim/nui.nvim" },
  {
    "snacks.nvim",
    opts = {
      styles = {
        float = { backdrop = 80 },
        notification = { wo = { wrap = true } },
        notification_history = {
          width = 0.8,
          wo = {
            signcolumn = "no",
            winhighlight = {
              NormalFloat = "SnacksNormal",
              FloatBorder = "SnacksWinBorder",
            },
          },
        },
        scratch = {
          height = 0.6,
          width = 0.8,
          wo = {
            winhighlight = {
              NormalFloat = "SnacksNormal",
              FloatBorder = "SnacksWinBorder",
            },
          },
        },
      },
      win = {
        wo = {
          winhighlight = {
            Normal = "SnacksNormal",
            NormalNC = "SnacksNormalNC",
            WinBar = "SnacksWinBar",
            WinBarNC = "SnacksWinBarNC",
            FloatBorder = "SnacksWinBorder",
          },
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        opts = {
          border = {
            text = { top_align = "right" },
          },
        },
        -- stylua: ignore
        format = {
          calculator = { pattern = "^=", icon = "=", lang = "vimnormal", title = title({ msg = "  Calculator ", kind = "calculator" }) },
          cmdline    = { pattern = "^:", icon = "❯", icon_hl_group = "MiniIconsGreen", lang = "vim", title = title({ msg = nvim_version, kind = "cmdline" }) },
          filter     = { pattern = "^:%s*!", icon = "", icon_hl_group = "MiniIconsGreen", lang = "bash", title = title({ msg = "  Shell ", kind = "filter" }) },
          help       = { pattern = "^:%s*he?l?p?%s+", icon = "", title = title({ msh = "  Help ", kind = "help" }) },
          input      = { icon = " ", opts = { border = { text = { top_align = "center" } } } },
          lua        = { kind = "lua", pattern = "^:%s*lua%s+", icon = "", icon_hl_group = "MiniIconsAzure", lang = "lua", title = title({ msg = lua_version, kind = "lua" }) },
          lua_eval   = { kind = "cmdline", pattern = { "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua", title = title({ msg = nvim_version, kind = "cmdline" }) },
          replace    = { kind = "search", pattern = "^.*s/", icon = "", lang = "regex", title = title({ msg = " 󰛔 Replace ", kind = "search" }), conceal = false },
        },
      },
      lsp = {
        documentation = { enabled = false },
        progress = { enabled = false },
        signature = { enabled = false },
        hover = { enabled = false },
      },
      popupmenu = { enabled = false },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%(mini%.*" },
            },
          },
          view = "mini",
        },
        {
          filter = {
            event = "notify",
            cond = function(msg) return msg.opts and (msg.opts.title or ""):find("tinymist") end,
          },
          view = "mini",
        },
      },
      views = {
        confirm = {
          border = { text = { top = title({ msg = "  Confirm ", views = "confirm" }) } },
          win_options = { winhighlight = { FloatTitle = "NoiceConfirmTitle" } },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
      },
    },
    config = function(_, opts)
      if vim.o.filetype == "lazy" then vim.cmd([[messages clear]]) end
      require("noice").setup(opts)
    end,
  },
}
