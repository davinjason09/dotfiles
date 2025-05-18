return {
  { "MunifTanjim/nui.nvim" },
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
        -- TODO: make title prettier by adding powerline symbol
        format = {
          calculator  = { pattern = "^=", icon = "=", lang = "vimnormal", title = "  Calculator " },
          cmdline     = { pattern = "^:", icon = "", lang = "vim", title = ("  v%s "):format(Utils.nvim_version()) },
          filter      = { pattern = "^:%s*!", icon = "", lang = "bash", title = "  Command " },
          help        = { pattern = "^:%s*he?l?p?%s+", icon = "", title = "  Help " },
          input       = false,
          lua         = false,
          lua_command = { kind = "cmdline", pattern = "^:%s*lua%s+", icon = "", lang = "lua", title = ("  %s "):format(_VERSION) },
          lua_value   = { kind = "lua", pattern = { "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua", title = ("  v%s "):format(Utils.nvim_version()) },
          replace     = { kind = "search", pattern = "^.*s/", icon = "", lang = "regex", title = " 󰛔 Replace ", conceal = false },
        },
      },
      lsp = {
        documentation = { enabled = false },
        progress = { enabled = false },
        signature = { enabled = false },
        hover = { enabled = false },
      },
      popupmenu = { enabled = false },
      ---@type NoiceRouteConfig[]
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
      presets = {
        bottom_search = true,
        command_palette = true,
      },
    },
  },
}
