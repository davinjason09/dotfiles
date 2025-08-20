local M = {}
local state = require("custom.terminal.state")
local utils = require("custom.terminal.utils")

---@type table<string, snacks.picker.Action.spec>
M.picker = {
  confirm = function(picker, item)
    picker:action("focus_term")
    utils.switch_term_buf(item.item.bufnr)
  end,
  focus_term = function(picker) picker:action("focus_preview") end,
  add_term = function(picker)
    utils.add_term()
    picker:find()
    picker:action("focus_term")
    utils.switch_term_buf(state.term_bufs[#state.term_bufs].bufnr)
  end,
  add_term_cmd = function(picker)
    local term_cmd = vim.fn.input("Command: ")
    utils.add_term(term_cmd, nil, { persist = true })
    picker:find()
    picker:action("focus_term")
    utils.switch_term_buf(state.term_bufs[#state.term_bufs].bufnr)
  end,
  delete_term = function(picker)
    local term_bufs = picker:selected({ fallback = true })
    for id, item in pairs(term_bufs) do
      local term_buf = item.item.bufnr
      local idx = utils.get_term("bufnr", term_buf)

      if idx then
        if state.last_term == term_buf then
          vim.schedule(function() utils.cycle_term_buf("prev") end)
        end
        table.remove(state.term_bufs, idx)
      else
        Snacks.notify.error("Terminal not found: " .. id .. " " .. term_buf)
      end
    end

    if #state.term_bufs == 0 then
      picker:close()
    else
      picker.list:set_selected()
      picker.list:set_target()
      picker:find()
    end

    vim.schedule(Utils.edit.escape)
  end,
  rename_term = function(picker, item)
    local idx = utils.get_term("bufnr", item.item.bufnr)

    if idx then
      local new_name = vim.fn.input("New Terminal Name: ", item.item.name)
      state.term_bufs[idx].name = new_name
      picker:find()

      if state.term_bufs[idx].bufnr == state.last_term then
        picker.preview:set_title(new_name)
        picker:update_titles()
      end
    else
      Snacks.notify.error("Terminal not found")
    end
  end,
  cycle_next = function() utils.cycle_term_buf("next") end,
  cycle_prev = function() utils.cycle_term_buf("prev") end,
  term_normal = function(self)
    ---@diagnostic disable-next-line: inject-field
    self.esc_timer = self.esc_timer or assert(vim.uv.new_timer())

    if self.esc_timer:is_active() then
      self.esc_timer:stop()
      vim.cmd("stopinsert")
    else
      self.esc_timer:start(200, 0, function() end)
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
