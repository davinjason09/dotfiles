local M = {}

M.State = {
  buflist_cache = {},
}

-- ╾╼ General Utilities ╾─────────────────────────────────────────────╼

---An `init` function to build multiple update events which is not supported yet by Heirline's update field
---@param opts (string | table)[] An array like table of autocmd events as either just a string or a table with custom patterns and callbacks.
---@return function Heirline init function
M.update_events = function(opts)
  if not vim.islist(opts) then opts = { opts } end

  return function(self)
    if not rawget(self, "once") then
      local function clear_cache() self._win_cache = nil end

      for _, event in ipairs(opts) do
        ---@type vim.api.keyset.create_autocmd
        local event_opts = { callback = clear_cache }
        if type(event) == "table" then
          event_opts.pattern = event.pattern
          if event.callback then
            local callback = event.callback
            event_opts.callback = function(ev)
              clear_cache()
              callback(self, ev)
            end
          end
          event = event[1]
        end
        vim.api.nvim_create_autocmd(event, event_opts)
      end
      self.once = true
    end
  end
end

---Redraw the statusline
---@param what? "stl"|"tab"|"all"
M.redraw = function(what)
  what = what or "stl"

  if what == "all" then
    vim.schedule(function() vim.cmd("redrawstatus | redrawtabline") end)
  elseif what == "tab" then
    vim.schedule(function() vim.cmd.redrawtabline() end)
  else
    vim.schedule(function() vim.cmd.redrawstatus() end)
  end
end

---Timer for spinner
local timer ---@type uv_timer_t?
local timer_running = false

M.start_spinner = function()
  if timer_running then return end

  timer = assert(vim.uv.new_timer())
  timer_running = true
  timer:start(
    0,
    50,
    vim.schedule_wrap(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "UpdateSpinner", modeline = false })
      M.redraw()
    end)
  )
end

M.stop_spinner = function()
  if not timer_running then return end

  timer:close()
  timer_running = false
  vim.schedule(function()
    vim.api.nvim_exec_autocmds("User", { pattern = "UpdateSpinner", modeline = false })
    vim.schedule(M.redraw)
  end)
end

---@alias PrettyPathOpts { type: "absolute"|"relative", split: boolean?, truncate: boolean? }

---Get the pretty path for a file
---@param filename string
---@param opts PrettyPathOpts
---@return string|{ parents: string, basename: string }
M.pretty_path = function(filename, opts)
  opts = vim.tbl_extend("force", { type = "relative", split = false, truncate = true }, opts) ---@type PrettyPathOpts

  local fname = vim.fn.fnamemodify(filename, opts.type == "absolute" and ":~" or ":.")
  local parents, basename = vim.fs.dirname(fname), vim.fs.basename(fname)

  parents = (parents ~= "." and parents ~= "") and parents or ""
  basename = (basename ~= "." and basename ~= "") and basename or "[No Name]"

  if opts.truncate then parents = parents:gsub("%f[^/][%w%d%p]+%f[/]", "…") end

  if opts.split then
    return { parents = parents, basename = basename }
  else
    return ("%s%s%s"):format(parents, basename ~= "[No Name]" and "/" or "", basename)
  end
end

M.get_bufs = function()
  return vim.tbl_filter(
    function(buf) return vim.api.nvim_get_option_value("buflisted", { buf = buf }) end,
    vim.api.nvim_list_bufs()
  )
end

---@param buf integer
---@return integer?
M.get_current_buffer_index = function(buf)
  for idx, b in ipairs(M.get_bufs()) do
    if b == buf then return idx end
  end

  return nil
end

---@param dir "left"|"right"
M.close_in_direction = function(dir)
  local buf = vim.api.nvim_get_current_buf()
  local idx = M.get_current_buffer_index(buf)

  if not idx then return end
  local buflist = M.get_bufs()
  local length = #buflist

  if not (idx == length and dir == "right") and not (idx == 1 and dir == "left") then
    local start = dir == "left" and 1 or idx + 1
    local _end = dir == "left" and idx - 1 or length
    for _, item in ipairs(vim.list_slice(buflist, start, _end)) do
      Snacks.bufdelete(item)
    end
  end
end

return M
