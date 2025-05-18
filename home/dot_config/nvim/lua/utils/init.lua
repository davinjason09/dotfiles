---@class Utils
local M = {}

setmetatable(M, {
  __index = function(t, key)
    t[key] = require("utils." .. key)
    return t[key]
  end,
})

---Get current nvim version
---@return string #The current nvim version
function M.nvim_version()
  local v = vim.version()
  return string.format("%d.%d.%d", v.major, v.minor, v.patch)
end

---Load a module lazily
---@param modname string The path to the module
---@return table #A table that lazily loads the module
function M.lazy_require(modname)
  return setmetatable({}, {
    __index = function(_, key) return require(modname)[key] end,
    __newindex = function(_, key, value) require(modname)[key] = value end,
  })
end

---Get the specified plugin
---@param name string The name of the plugin
function M.get_plugin(name) return require("lazy.core.config").spec.plugins[name] end

---Check if the plugin exists
---@param plugin string The name of the plugin
function M.has(plugin) return M.get_plugin(plugin) ~= nil end

---Execute code on `VeryLazy` event
---@param func fun() The function to run on `VeryLazy` event
function M.on_very_lazy(func)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function() func() end,
  })
end

---Get the specified plugin's options
---@param name string The name of the plugin
function M.opts(name)
  local plugin = M.get_plugin(name)

  if not plugin then return {} end

  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

---Check if the plugin is loaded
---@param name string The name of the plugin
function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---Execute code when a plugin is loaded
---@param name string            The name of the plugin
---@param func fun(name: string) The code to load when the plugin is loaded
function M.on_load(name, func)
  if M.is_loaded(name) then
    func(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          func(name)
          return true
        end
      end,
    })
  end
end

---Deduplicate a list
---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
  local ret = {}
  local seen = {}

  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end

  return ret
end

-- Optimized treesitter foldexpr
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filtype, don't bother checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then return "0" end

    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end

  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

return M
