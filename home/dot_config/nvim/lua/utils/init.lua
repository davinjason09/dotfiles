---@class Utils
---@field format Utils.format
---@field mini   Utils.mini
---@field picker Utils.picker
---@field ui     Utils.ui
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

-- Delay notifications till vim.notify was replaced or after 500ms
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua#L138
function M.lazy_notify()
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
      ---@diagnostic disable-next-line: no-unknown
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

-- Get all LSP clients attached to the current buffer
---@return string[] #A list of LSP client names
function M.get_lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local attached = {}

  for _, client in ipairs(clients) do
    if client.name ~= "copilot" then table.insert(attached, client.name) end
  end

  Utils.dedup(attached)
  return attached
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<C-g>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false) end
end

---Save the current cursor position
function M.save_cursor_pos() vim.b[0].cursor_pos = vim.api.nvim_win_get_cursor(0) end

---Restore the cursor position
---@param offset? {row: number, col: number} The offset to move the cursor
function M.restore_cursor(offset)
  if vim.b.cursor_pos then
    local cursor_pos = vim.b.cursor_pos

    if offset then
      cursor_pos[1] = cursor_pos[1] + (offset.row or 0)
      cursor_pos[2] = cursor_pos[2] + (offset.col or 0)
    end

    -- Ensure the cursor position is within the buffer's line count
    local line_count = vim.api.nvim_buf_line_count(0)
    if cursor_pos[1] < 1 or cursor_pos[1] > line_count then
      cursor_pos[1] = math.max(1, math.min(line_count, cursor_pos[1]))
    end

    vim.api.nvim_win_set_cursor(0, cursor_pos)
    vim.b.cursor_pos = nil
  end
end

function M.clear_lsp_log()
  local log_path = vim.lsp.get_log_path()

  if log_path and vim.fn.filereadable(log_path) then
    local file_size = vim.fn.getfsize(log_path)

    if file_size > Defaults.max_lsp_log_size then
      os.remove(log_path)
      vim.notify("LSP log file exceeded size limit and was deleted")
    end
  end
end

return M
