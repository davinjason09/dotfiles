local M = {}
local state = require("custom.terminal.state")

---@param cmd string | string[]
---@param opts? table
---@return integer
local function jobstart(cmd, opts)
  opts = opts or {}
  return vim.fn.jobstart(cmd, vim.tbl_isempty(opts) and vim.empty_dict() or opts)
end

---@param key "bufnr" | "cmd" | "name"
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
  local term_name = cmd and (type(cmd) == "table" and cmd[1] or cmd) or name or "Terminal" --[[@as string]]
  term_name = term_name:sub(1, 1):upper() .. term_name:sub(2)

  local term_buf = {
    bufnr = vim.api.nvim_create_buf(false, true),
    cmd = Snacks.terminal.parse(cmd or vim.o.shell), ---@diagnostic disable-line: invisible
    name = term_name,
    opts = opts,
  }

  table.insert(state.term_bufs, term_buf)
end

---@param buf integer
M.switch_term_buf = function(buf)
  local picker = assert(Snacks.picker.get()[1])

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      local id, term = assert(M.get_term("bufnr", buf))
      local opts = term.opts or {} ---@type TermOpts

      if opts.persist then
        buf = vim.api.nvim_create_buf(false, true)
        state.term_bufs[id].bufnr = buf
      end
    end

    state.last_term = buf
    state.term_win:set_buf(buf)
    state.term_win:map()

    local details = vim.iter(state.term_bufs):find(function(x) return x.bufnr == buf end)
    picker.preview:set_title(details.name)
    picker:update_titles()

    if vim.bo[buf].buftype ~= "terminal" then
      local is_term = picker:current_win() == "preview"
      if not is_term then picker:action("focus_term") end

      jobstart(details.cmd, { term = true })
      vim.schedule(function() picker:find() end)

      -- Since the input field is automatically hidden, focus to the list no matter whether if the
      -- previous window was the input or not.
      if not is_term then picker:action("focus_list") end
    end
  end)
end

---@param dir "prev" | "next"
M.cycle_term_buf = function(dir)
  local cur_idx = M.get_term("bufnr", state.last_term)
  if not cur_idx then
    M.switch_term_buf(state.term_bufs[1].bufnr)
    return
  end

  local new_idx = (cur_idx + (dir == "prev" and -2 or 0)) % #state.term_bufs
  local next_buf = state.term_bufs[new_idx + 1].bufnr
  M.switch_term_buf(next_buf)
end

return M
