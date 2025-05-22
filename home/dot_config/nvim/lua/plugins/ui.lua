---Add powerline symbols to the title of cmdline_popup
---@param msg string
---@param kind string
local function title(msg, kind)
  local powerline_hl = "NoiceCmdlinePopupBorder" .. kind:sub(1, 1):upper() .. kind:sub(2)
  return {
    { "", powerline_hl },
    { msg },
    { "", powerline_hl },
  }
end

local nvim_version = ("  v%s "):format(Utils.nvim_version())
local lua_version = ("  %s "):format(_VERSION)

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
        format = {
          calculator = { pattern = "^=", icon = "=", lang = "vimnormal", title = title("  Calculator ", "calculator") },
          cmdline    = { pattern = "^:", icon = "❯", icon_hl_group = "MiniIconsGreen", lang = "vim", title = title(nvim_version, "cmdline") },
          filter     = { pattern = "^:%s*!", icon = "", icon_hl_group = "MiniIconsGreen", lang = "bash", title = title("  Shell ", "filter") },
          help       = { pattern = "^:%s*he?l?p?%s+", icon = "", title = title("  Help ", "help") },
          input      = { icon = " ", opts = { border = { text = { top_align = "center" } } } },
          lua        = { kind = "lua", pattern = "^:%s*lua%s+", icon = "", icon_hl_group = "MiniIconsAzure", lang = "lua", title = title(lua_version, "lua") },
          lua_eval   = { kind = "cmdline", pattern = { "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua", title = title(nvim_version, "cmdline") },
          replace    = { kind = "search", pattern = "^.*s/", icon = "", lang = "regex", title = title(" 󰛔 Replace ", "search"), conceal = false },
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
      presets = {
        bottom_search = true,
        command_palette = true,
      },
    },
  },
}
