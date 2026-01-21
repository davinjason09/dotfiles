local M = {}

local function find_plugin()
  local plugin_names = vim.tbl_map(
    function(plugin) return plugin.name end,
    require("lazy").plugins()
  )
  local items = vim.tbl_map(function(name) return { text = name, item = name } end, plugin_names)
  table.sort(items, function(a, b) return a.item < b.item end)

  return items
end

---@class snacks.picker.reload.Config: snacks.picker.Config
M.source = {
  title = "Reload Plugin",
  format = "text",
  finder = find_plugin,
  layout = { preset = "vscode" },
  confirm = function(picker, item)
    picker:close()
    require("lazy").reload({ plugins = { item.item } })
  end,
}

return M
