local M = {}
local state = require("custom.terminal.state")
local utils = require("custom.terminal.utils")

---@type table<string, snacks.picker.Action.spec>
M.picker = {
  confirm = function(picker, item)
    if picker:current_win() == "input" then picker:action("clear_input") end

    picker:action("focus_term")
    vim.schedule(function() utils.switch_term_buf(item.item.bufnr) end)
  end,
  focus_term = function(picker) picker:action("focus_preview") end,
  startinsert = function() vim.cmd.startinsert() end,
  add_term = function(picker)
    utils.add_term()
    picker:action("focus_term")
    utils.switch_term_buf(state.term_bufs[#state.term_bufs].bufnr)
  end,
  add_term_cmd = function(picker)
    local term_cmd = vim.fn.input("Command: ")
    utils.add_term(term_cmd, nil, { persist = true })
    picker:action("focus_term")
    utils.switch_term_buf(state.term_bufs[#state.term_bufs].bufnr)
  end,
  delete_term = function(picker)
    local term_bufs = picker:selected({ fallback = true })
    for _, item in pairs(term_bufs) do
      local term_buf = item.item

      table.insert(state.buf_to_clear, term_buf.bufnr)

      if state.last_term == term_buf.bufnr then
        vim.schedule(function() utils.cycle_term_buf("prev") end)
      end
    end

    state.term_bufs = vim.tbl_filter(
      function(t) return not vim.tbl_contains(state.buf_to_clear, t.bufnr) end,
      state.term_bufs
    )

    if #state.term_bufs == 0 then
      state.last_term = nil
      picker:close()
    else
      picker.list:set_selected()
      picker.list:set_target()
      picker:find()
    end

    vim.schedule(Utils.edit.escape)
  end,
  rename_term = function(picker, item)
    local new_name = vim.fn.input("New Terminal Name: ", item.item.name)
    state.term_bufs[item.idx].name = new_name
    picker:find()
    picker.list:move(item.idx, true)

    if state.term_bufs[item.idx].bufnr == state.last_term then
      picker.preview:set_title(new_name)
      picker:update_titles()
    end

    picker:action("startinsert")
  end,
  cycle_next = function() utils.cycle_term_buf("next") end,
  cycle_prev = function() utils.cycle_term_buf("prev") end,
  term_normal = function(picker)
    ---@diagnostic disable-next-line: inject-field
    picker.esc_timer = picker.esc_timer or assert(vim.uv.new_timer())

    if picker.esc_timer:is_active() then
      picker.esc_timer:stop()
      picker:action("stopinsert")
    else
      picker.esc_timer:start(200, 0, function() end)
      vim.api.nvim_exec_autocmds("User", { pattern = "ForceRedraw", modeline = false })
      return "<ESC>"
    end
  end,
  goto_file = function(self)
    local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
    if f ~= "" then
      Snacks.notify.warn("No file under cursor")
    else
      self:close()
      vim.schedule(function() vim.cmd("e " .. f) end)
    end
  end,
}

return M
