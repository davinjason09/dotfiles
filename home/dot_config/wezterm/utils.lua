local wez = require("wezterm") ---@type Wezterm
local M = {}

M.isWSL = function(domain) return wez.target_triple == "x86_64-pc-windows-msvc" and domain ~= "local" end

-- taken from nvim's vim.gsplit implementation

--- @class gsplit.Opts
--- @field plain? boolean
--- @field trimempty? boolean

--- @param s string String to split
--- @param sep string Separator or pattern
--- @param opts? gsplit.Opts Keyword arguments |kwargs|:
--- @return fun():string? : Iterator over the split components
M.gsplit = function(s, sep, opts)
  opts = opts or {}
  local plain, trimempty = opts.plain, opts.trimempty

  local start = 1
  local done = false

  local segs = {}
  local empty_start = true

  --- @param i integer?
  --- @param j integer
  --- @param ... unknown
  --- @return string
  --- @return ...
  local function _pass(i, j, ...)
    if i then
      assert(j + 1 > start, "Infinite loop detected")
      local seg = s:sub(start, i - 1)
      start = j + 1
      return seg, ...
    else
      done = true
      return s:sub(start)
    end
  end

  return function()
    if trimempty and #segs > 0 then
      return table.remove(segs)
    elseif done or (s == "" and sep == "") then
      return nil
    elseif sep == "" then
      if start == #s then done = true end
      return _pass(start + 1, start)
    end

    ---@diagnostic disable: param-type-mismatch
    local seg = _pass(s:find(sep, start, plain))

    if trimempty and seg ~= "" then
      empty_start = false
    elseif trimempty and seg == "" then
      while not done and seg == "" do
        table.insert(segs, 1, "")
        seg = _pass(s:find(sep, start, plain))
      end
      if done and seg == "" then
        return nil
      elseif empty_start then
        empty_start = false
        segs = {}
        return seg
      end
      if seg ~= "" then table.insert(segs, 1, seg) end
      return table.remove(segs)
    end
    ---@diagnostic enable: param-type-mismatch

    return seg
  end
end

return M
