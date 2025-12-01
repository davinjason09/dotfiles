local M = {}

M._buflist_cache = {}

M.Statusline = require("custom.lines.statusline")

M.setup = function()
  local Comp = require("custom.lines.components")
  local U = require("custom.lines.utils")

  -- Setup clock update timer
  vim.uv.new_timer():start(
    (60 - tonumber(os.date("%S"))) * 1000,
    60000,
    vim.schedule_wrap(
      function() vim.api.nvim_exec_autocmds("User", { pattern = "UpdateTime", modeline = false }) end
    )
  )

  Comp.AI.setup()
end

return M
