---@class Utils.edit
local M = {}

M.CREATE_UNDO = Snacks.util.keycode("<C-g>u")

M.create_undo = function()
  if vim.api.nvim_get_mode().mode == "i" then vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false) end
end

M.escape = function() vim.api.nvim_feedkeys(Snacks.util.keycode("<ESC>"), "n", false) end

M.enter = function() vim.api.nvim_feedkeys(Snacks.util.keycode("<CR>"), "n", false) end

---Save the current cursor position
M.save_cursor_pos = function() vim.b.cursor_pos = vim.api.nvim_win_get_cursor(0) end

---Restore the cursor position
---@param offset? {row: number, col: number} The offset to move the cursor
M.restore_cursor = function(offset)
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
  else
    vim.schedule(function()
      if vim.fn.line("'c") ~= 0 then
        vim.cmd("normal! g`c")
        vim.api.nvim_buf_del_mark(0, "c")
      end
    end)
  end
end

---Add new line without entering insert mode
---@param dir "down" | "up"
M.add_line = function(dir)
  local ft = vim.bo.filetype
  local buftype = vim.bo.buftype

  if not vim.bo.modifiable then return end

  -- Inside cmdline-window, execute the command with enter
  if ft == "vim" and buftype == "nofile" then M.enter() end

  local cmd = dir == "down" and "%s] %sj" or "%s[ %sk"
  local count = vim.v.count1

  vim.fn.feedkeys(cmd:format(count, count))
end

-- Preserve cursor when commenting
M.comment = function()
  M.save_cursor_pos()
  local mode = vim.fn.mode()

  if mode == "n" or mode == "i" then
    vim.cmd.norm("gcc")
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd.norm("gc")
  end

  M.restore_cursor()
end

-- Emacs-like paste
---@param key "p" | "P"
M.paste = function(key)
  if vim.fn.getreg('"') == "" then return end

  local is_normal = vim.fn.mode() == "n"
  if is_normal and vim.fn.getregtype('"') == "V" then M.save_cursor_pos() end

  vim.cmd("normal! " .. vim.v.count1 .. key)
  M.restore_cursor({ row = key == "p" and 1 or 0 })
end

-- Smart delete
---@param key string
---@param mode string
---@return string
M.smart_delete = function(key, mode)
  if mode == "n" then
    local line = vim.api.nvim_get_current_line()
    return (line:match("^%s*$") and '"_' or "") .. key
  else
    local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
    local all_space = table.concat(lines, ""):match("^%s*$")
    return (all_space and '"_' or "") .. key
  end
end

M.completion = {}

---@param item vim.lsp.inline_completion.Item
---@return string?
local function get_insert_text(item)
  local text = item.insert_text

  if type(text) == "table" and text.value then return text.value end
  return type(text) == "string" and text or ""
end

---@param item vim.lsp.inline_completion.Item
---@param new_text string
local function set_insert_text(item, new_text)
  local text = item.insert_text
  vim.print(new_text, text)

  if type(text) == "table" then
    item.insert_text = vim.tbl_extend("force", text, { value = new_text })
  else
    item.insert_text = new_text
  end

  return item
end

---@param item vim.lsp.inline_completion.Item
local function get_next_word(item)
  local text = get_insert_text(item)

  local start_row = item.range.start_row
  local start_col = item.range.start_col

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1

  local cur_line = vim.api.nvim_buf_get_text(0, start_row, start_col, cursor_row, cursor_col, {})
  local cur_text = table.concat(cur_line, "\n")

  local adjusted = vim.startswith(text, cur_text) and text:sub(#cur_text + 1) or text
  local next_word = adjusted:match("[%s:]*[^%s][%w_]*[(%[]?[)%]]?") or adjusted

  return cur_text .. next_word
end

---@param item vim.lsp.inline_completion.Item
local function get_next_line(item)
  local text = get_insert_text(item)
  return vim.split(text, "\n", { trimempty = true })[1] or text
end

---@param item vim.lsp.inline_completion.Item
M.completion.accept_word = function(item) return set_insert_text(item, get_next_word(item)) end

---@param item vim.lsp.inline_completion.Item
M.completion.accept_line = function(item) return set_insert_text(item, get_next_line(item)) end

return M
