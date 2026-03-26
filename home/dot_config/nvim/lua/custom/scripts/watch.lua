local M = {}

M.watches = {} ---@type table<string, uv_fs_event_t>>

---@param path string
---@param callback fun(err: string?, filename: string, events: uv.aliases.fs_event_start_callback_events)
M.start = function(path, callback)
  if M.watches[path] ~= nil then return end

  local watch = assert(vim.uv.new_fs_event())
  local ok, err = watch:start(path, {}, callback)

  if not ok then
    vim.notify("Failed to watch " .. path .. ": " .. err, vim.log.levels.ERROR)
    return watch:is_closing() or watch:close()
  end

  M.watches[path] = watch
end

return M
