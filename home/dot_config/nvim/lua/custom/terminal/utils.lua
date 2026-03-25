local M = {}
local state = require("custom.terminal.state")

---@param term TermBuf
M.open_term = function(term)
  vim.api.nvim_buf_call(term.buf, function()
    if vim.bo[term.buf].buftype == "terminal" then return end

    local ok, res = pcall(vim.fn.jobstart, term.cmd, { term = true })

    if not ok then
      local message = ("%s\nSwitching to previous terminal.."):format(res:gsub("Vim:E%d+: ", ""))
      vim.notify(message, vim.log.levels.ERROR)

      table.insert(state.buf_to_clear, term.buf)
      state.term_bufs = vim.tbl_filter(function(t) return t.buf ~= term.buf end, state.term_bufs)
      return M.cycle_term_buf("prev")
    end

    term.job_id = res
    vim.cmd("noh")
  end)
end

---@param key "buf"|"cmd"|"name"|"opts"|"job_id"
---@param value any
---@return integer?, TermBuf?
M.get_term = function(key, value)
  for idx, term in ipairs(state.term_bufs) do
    if vim.deep_equal(term[key], value) then return idx, term end
  end

  return nil, nil
end

---@param cmd (string | string[])?
---@param name string?
---@param opts TermOpts?
M.add_term = function(cmd, name, opts)
  if not state.term_bufs then state.term_bufs = {} end

  opts = vim.tbl_extend("force", { persist = false, auto_close = false }, opts or {})

  local parsed_cmd = Snacks.terminal.parse(cmd or vim.o.shell) ---@diagnostic disable-line: access-invisible
  local term_name = cmd and parsed_cmd[1] or name or "Terminal"
  term_name = term_name:sub(1, 1):upper() .. term_name:sub(2)

  ---@type TermBuf
  local term_buf = {
    buf = vim.api.nvim_create_buf(false, true),
    cmd = parsed_cmd,
    name = term_name,
    opts = opts,
  }

  M.open_term(term_buf)
  table.insert(state.term_bufs, term_buf)
  state.last_term = term_buf.buf
end

---@param buf integer
M.switch_term_buf = function(buf)
  local picker = Snacks.picker.get()[1]
  if not picker then return end

  vim.schedule(function()
    local id, term = M.get_term("buf", buf)
    if not id or not term then return end

    state.last_term = buf
    picker.preview.win:set_buf(buf)
    picker.preview.win:map()
    vim.b[buf].managed_term = true

    picker.preview:set_title(term.name)
    picker:update_titles()

    vim.schedule(function() picker.list:move(id, true) end)
    vim.cmd("checktime")
  end)
end

---@param dir "prev"|"next"
M.cycle_term_buf = function(dir)
  if #state.term_bufs == 0 then return end

  local cur_idx = M.get_term("buf", state.last_term)
  if not cur_idx then return M.switch_term_buf(state.term_bufs[1].buf) end

  local new_idx = (cur_idx + (dir == "prev" and -2 or 0)) % #state.term_bufs
  local next_buf = state.term_bufs[new_idx + 1].buf
  M.switch_term_buf(next_buf)
end

return M
