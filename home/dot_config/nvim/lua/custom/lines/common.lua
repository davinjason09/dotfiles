local M = {}

local U = require("custom.lines.utils")

M.components = {
  Align = { provider = "%=" },

  ---@param n? number The amount of spaces to add
  ---@return table
  Space = function(n) return { provider = string.rep(" ", n or 1) } end,

  ---@alias SeparatorHL { fg?: string, bg?: string } | fun(self: table): { fg?: string, bg?: string }

  ---@alias SepOpts {
  ---  icon: string,
  ---  init?: (string | table)[],
  ---  hl: SeparatorHL,
  ---  update?: string | table | (string | table)[] | fun(self: table): boolean
  ---}

  ---@param opts SepOpts
  ---@return table
  Separator = function(opts)
    local comp = { provider = opts.icon, hl = opts.hl }

    if opts.init then comp.init = U.update_events(opts.init) end
    if opts.update then comp.update = opts.update end

    return comp
  end,
}

return M
