local U = require("custom.lines.utils")

return {
  static = {
    clock_icons = { "󱑋", "󱑌", "󱑍", "󱑎", "󱑏", "󱑐", "󱑑", "󱑒", "󱑓", "󱑔", "󱑕", "󱑖" },
  },
  update = { "ModeChanged", "User", pattern = { "*:*", "UpdateTime" }, callback = function() U.redraw() end },
  provider = function(self)
    local hour = os.date("%I")
    local icon = self.clock_icons[tonumber(hour)]

    return (" %s %s "):format(icon, os.date("%H:%M"))
  end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color(), bold = true } end,
  setup = function()
    if U.State.clock_timer then return end

    local timer = assert(vim.uv.new_timer())
    U.State.clock_timer = timer

    timer:start(
      (60 - tonumber(os.date("%S"))) * 1000,
      60000,
      vim.schedule_wrap(function() vim.api.nvim_exec_autocmds("User", { pattern = "UpdateTime", modeline = false }) end)
    )
  end,
}
