---@class Utils
---@field edit       Utils.edit
---@field format     Utils.format
---@field mini       Utils.mini
---@field treesitter Utils.treesitter
local M = {}

setmetatable(M, {
  __index = function(t, key)
    t[key] = require("utils." .. key)
    return t[key]
  end,
})

---Get current nvim version
---@return string #The current nvim version
M.nvim_version = function()
  local v = vim.version() ---@diagnostic disable-line: call-non-callable
  return ("%d.%d.%d"):format(v.major, v.minor, v.patch)
end

---Load a module lazily
---@param modname string The path to the module
---@return table #A table that lazily loads the module
M.lazy_require = function(modname)
  return setmetatable({}, {
    __index = function(_, key) return require(modname)[key] end,
    __newindex = function(_, key, value) require(modname)[key] = value end,
  })
end

---Get the specified plugin
---@param name string The name of the plugin
M.get_plugin = function(name) return require("lazy.core.config").spec.plugins[name] end

---Check if the plugin exists
---@param plugin string The name of the plugin
M.has = function(plugin) return M.get_plugin(plugin) ~= nil end

---Execute code on `VeryLazy` event
---@param func fun() The function to run on `VeryLazy` event
M.on_very_lazy = function(func)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function() func() end,
  })
end

---Get the specified plugin's options
---@param name string The name of the plugin
M.opts = function(name)
  local plugin = M.get_plugin(name)

  if not plugin then return {} end

  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

---Check if the plugin is loaded
---@param name string The name of the plugin
M.is_loaded = function(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---Execute code when a plugin is loaded
---@param name string            The name of the plugin
---@param func fun(name: string) The code to load when the plugin is loaded
M.on_load = function(name, func)
  if M.is_loaded(name) then
    func(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(ev)
        if ev.data == name then
          func(name)
          return true
        end
      end,
    })
  end
end

-- Delay notifications till vim.notify was replaced or after 500ms
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua#L138
M.lazy_notify = function()
  local notifs = {}
  local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end

  local orig = vim.notify
  vim.notify = temp

  local timer = assert(vim.uv.new_timer())
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then replay() end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

---Deduplicate a list
---@generic T
---@param list T[]
---@param opts? { func: fun(x: T) }
---@return T[]
M.dedup = function(list, opts)
  opts = opts or {}
  local ret = {}
  local seen = {}

  for _, v in ipairs(list) do
    local key = opts.func and opts.func(v) or v

    if not seen[key] then
      table.insert(ret, v)
      seen[key] = true
    end
  end

  return ret
end

---@alias IconType "file"|"filetype"|"directory"

---Get the icon and color for a file based on its filename and extension
---@param entry { fs_type: IconType, path: string } The file entry containing type and path
---@return string, string, boolean The icon, color, and whether it's a default icon
M.get_icon = function(entry)
  local MiniIcons = _G.MiniIcons or require("mini.icons")
  local name = vim.fn.fnamemodify(entry.path, ":t")
  local icon, color, is_default = MiniIcons.get(entry.fs_type, name)

  if name == "init.lua" and entry.fs_type == "file" then
    local in_runtime_path = vim
      .iter(vim.api.nvim_list_runtime_paths())
      :any(function(path) return entry.path:find(path) ~= nil end)

    if in_runtime_path then goto continue end

    -- If the file is not in the runtime path, check for special icons
    -- Currently this is a workaround due to limitation of mini.icons
    is_default = true
    for key, value in pairs(Defaults.special_ft_icons) do
      if entry.path:find(key) ~= nil then
        icon, color, is_default = value[1], value[2], false
        break
      end
    end
  end

  ::continue::
  if is_default and entry.fs_type ~= "directory" then
    local ft = vim.filetype.match({ filename = entry.path }) or ""
    icon, color, is_default = MiniIcons.get("filetype", ft)
  end

  return icon .. " ", color, is_default
end

---Get all LSP clients attached to the current buffer
---@return string[] A list of LSP client names
M.get_lsp_clients = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local attached = {}

  for _, client in ipairs(clients) do
    if client.name ~= "copilot" then table.insert(attached, client.name) end
  end

  M.dedup(attached)
  return attached
end

---Clear LSP log if it exceeds a certain size
M.clear_lsp_log = function()
  local log_path = vim.lsp.get_log_path()

  if log_path and vim.fn.filereadable(log_path) then
    local file_size = vim.fn.getfsize(log_path)

    if file_size > Defaults.bigfile.size then
      os.remove(log_path)
      vim.notify("LSP log file exceeded size limit and was deleted")
    end
  end
end

return M
