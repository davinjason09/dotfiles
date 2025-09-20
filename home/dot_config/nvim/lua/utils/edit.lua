---@class Utils.edit
local M = {}

M.CREATE_UNDO = Snacks.util.keycode("<C-g>u")

function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false) end
end

function M.escape()
  local ESC = Snacks.util.keycode("<ESC>")
  vim.fn.feedkeys(ESC, "n")
end

---Save the current cursor position
function M.save_cursor_pos() vim.b.cursor_pos = vim.api.nvim_win_get_cursor(0) end

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
function M.add_line(dir)
  local ft = vim.bo.filetype
  local buftype = vim.bo.buftype

  if not vim.bo.modifiable then return end

  -- In Vim command mode, execute the command with enter
  if ft == "vim" and buftype == "nofile" then
    local CR = Snacks.util.keycode("<CR>")
    vim.fn.feedkeys(CR, "n")
  end

  local cmd = dir == "down" and "%s] %sj" or "%s[ %sk"
  local count = vim.v.count1

  vim.fn.feedkeys(cmd:format(count, count))
end

-- Preserve cursor when commenting
function M.comment()
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
function M.paste(key)
  local reg_type = vim.fn.getregtype('"')
  local opts = nil

  if vim.fn.getreg('"') == "" then return end
  if reg_type == "V" and vim.fn.mode() == "n" then M.save_cursor_pos() end
  if key == "p" then opts = { row = 1 } end

  vim.cmd("normal! " .. vim.v.count1 .. key)
  M.restore_cursor(opts)
end

-- Smart delete
---@param key string
---@param mode string
function M.smart_delete(key, mode)
  if mode == "n" then
    local line = vim.api.nvim_get_current_line()
    return (line:match("^%s*$") and '"_' or "") .. key
  elseif mode == "v" then
    local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
    local all_space = true
    for _, line in ipairs(lines) do
      if not line:match("^%s*$") then
        all_space = false
        break
      end
    end
    return (all_space and '"_' or "") .. key
  end
end

return M
