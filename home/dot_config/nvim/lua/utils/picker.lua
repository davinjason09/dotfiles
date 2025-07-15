---@class Utils.picker
local M = {}

local Snacks = require("snacks")
local a = Snacks.picker.util.align

---@param str string
local function display_termcodes(str)
  return str:gsub(string.char(9), "<TAB>"):gsub("\6", "<C-F>"):gsub(" ", "<Space>")
end

M.options = function()
  local options = {}
  for _, v in pairs(vim.api.nvim_get_all_options_info()) do
    local ok, value = pcall(vim.api.nvim_get_option_value, v.name, {})
    if ok then
      v.value = value
      table.insert(options, v)
    end
  end

  table.sort(options, function(left, right) return left.name < right.name end)

  ---@param item snacks.picker.Item
  local function format_item(item)
    local ret = {}
    local k = item.item
    local type_spacing = 12 - #k.type - 2
    local scope_spacing = 11 - #k.scope - 2

    ret[#ret + 1] = { a(k.name, 20), "Keyword" }
    ret[#ret + 1] = { "[", "Delimiter" }
    ret[#ret + 1] = { k.type, "Type" }
    ret[#ret + 1] = { a("]", type_spacing), "Delimiter" }
    ret[#ret + 1] = { "[", "Delimiter" }
    ret[#ret + 1] = { k.scope, "Constant" }
    ret[#ret + 1] = { a("]", scope_spacing), "Delimiter" }
    ret[#ret + 1] = { display_termcodes(tostring(k.value)), "Text" }

    return ret
  end

  local items = vim.tbl_map(
    function(option)
      return {
        text = string.format(
          "%s %s %s %s",
          option.name,
          option.type,
          option.scope,
          display_termcodes(tostring(option.value))
        ),
        item = option,
      }
    end,
    options
  )

  Snacks.picker.pick({
    title = "Options",
    format = function(item, _) return format_item(item) end,
    items = items,
    layout = {
      hidden = { "preview" },
      layout = { width = 0.8, height = 0.5 },
    },
    confirm = {
      action = function(picker, selection)
        picker:close()

        local esc = ""
        if vim.fn.mode() == "i" then
          esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        end

        local keys = ""
        if selection.item.type == "boolean" then
          keys = string.format("%s:set %s!", esc, selection.item.name)
        else
          keys = string.format("%s:set %s=%s", esc, selection.item.name, selection.item.value)
        end

        vim.api.nvim_feedkeys(keys, "m", true)
      end,
    },
  })
end

      vim.api.nvim_feedkeys(keys, "m", true)
  })
end

M.reload = function()
  local plugins = require("lazy").plugins()
  local plugin_names = vim.tbl_map(function(plugin) return plugin.name end, plugins)

  local items = vim.tbl_map(
    function(name)
      return {
        text = name,
        item = name,
      }
    end,
    plugin_names
  )

  Snacks.picker.pick({
    title = "Reload Plugins",
    format = "text",
    items = items,
    layout = { preset = "vscode" },
    confirm = {
      action = function(picker, selection)
        picker:close()
        local plugin_name = selection.item
        require("lazy").reload({ plugins = { plugin_name } })
      end,

M.chezmoi = function()
  local results = require("chezmoi.commands").list({
    args = {
      "--path-style",
      "absolute",
      "--include",
      "files",
      "--exclude",
      "externals",
    },
  })

  local items = {}
  for _, file in ipairs(results) do
    table.insert(items, {
      text = file,
      file = file,
    })
  end

  Snacks.picker.pick({
    title = "Chezmoi Files",
    items = items,
    confirm = function(picker, item)
      picker:close()
      require("chezmoi.commands").edit({
        targets = { item.text },
        args = { "--watch" },
      })
    end,
  })
end

return M
