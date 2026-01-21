local M = {}

local a = Snacks.picker.util.align

---@param str string
---@param filler string?
local function display_termcodes(str, filler)
  filler = filler or ""

  return str
    :gsub(string.char(9), filler .. "<Tab>" .. filler)
    :gsub("\6", filler .. "<C-f>" .. filler)
    :gsub(" ", filler .. "<Space>" .. filler)
end

---@param item snacks.picker.Item
local function format_item(item)
  local ret = {}
  local k = item.item
  local type_spacing = 14 - #k.type - 2
  local scope_spacing = 13 - #k.scope - 2

  ret[#ret + 1] = { a(k.name, 20), "Keyword" }
  ret[#ret + 1] = { "[", "Delimiter" }
  ret[#ret + 1] = { k.type, "Type" }
  ret[#ret + 1] = { a("]", type_spacing), "Delimiter" }
  ret[#ret + 1] = { "[", "Delimiter" }
  ret[#ret + 1] = { k.scope, "Constant" }
  ret[#ret + 1] = { a("]", scope_spacing), "Delimiter" }

  local value = display_termcodes(tostring(k.value), "|")
  for _, s in ipairs(vim.split(value, "|", { trimempty = true })) do
    ret[#ret + 1] = { s, s:match("<.*>") and "NonText" or "Text" }
  end

  return ret
end

---@class snacks.picker.options.Config: snacks.picker.Config
M.source = {
  title = "Options",
  layout = {
    hidden = { "preview" },
    layout = { width = 0.8, height = 0.5 },
  },
  finder = function()
    local options = {}
    for _, v in pairs(vim.api.nvim_get_all_options_info()) do
      local ok, value = pcall(vim.api.nvim_get_option_value, v.name, {})
      if ok then
        v.value = value
        table.insert(options, v)
      end
    end

    table.sort(options, function(left, right) return left.name < right.name end)

    local res = vim.tbl_map(function(o)
      return {
        -- stylua: ignore
        text = table.concat({ o.name, o.type, o.scope, display_termcodes(tostring(o.value)) }, " "),
        item = o,
      }
    end, options)

    return res
  end,
  format = format_item,
  confirm = function(picker, item)
    picker:close()

    vim.schedule(function()
      local ESC = ""
      if vim.fn.mode() == "i" then ESC = Snacks.util.keycode("<ESC>") end

      local keys = ""
      if item.item.type == "boolean" then
        keys = ("%s:set %s!"):format(ESC, item.item.name)
      else
        keys = ("%s:set %s=%s"):format(ESC, item.item.name, item.item.value)
      end

      vim.api.nvim_feedkeys(keys, "m", true)
    end)
  end,
}

return M
