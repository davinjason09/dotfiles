local M = {}

-- Use virtual_lines for the current line diagnstics and use virtual_text for the rest
-- Taken from https://github.com/joe-p/kickstart.nvim/blob/4f756cf63ec2d4eea293918e086096ff984eebc9/lua/joe-p/diagnostic.lua

-- Get the window id of a buffer
---@param bufnr integer
local function buf_to_win(bufnr)
  local cur_win = vim.api.nvim_get_current_win()

  -- Check if the current window has the buffer
  if vim.api.nvim_win_get_buf(cur_win) == bufnr then return cur_win end

  -- Else, find a visible windows with this buffer
  local win_ids = vim.fn.win_findbuf(bufnr)
  local cur_tab = vim.api.nvim_get_current_tabpage()

  for _, win_id in ipairs(win_ids) do
    if vim.fn.win_id2tabwin(win_id)[1] == cur_tab then return win_id end
  end

  return cur_win
end

-- Split string into lines of a maximum width
-- Split will only occur on space for readability
---@param str string
---@param max_width integer
local function split_line(str, max_width)
  if #str <= max_width then return { str } end

  local lines = {}
  local current_line = ""

  for word in string.gmatch(str, "%S+") do
    if #current_line + #word + 1 > max_width then
      table.insert(lines, current_line)
      current_line = word
    else
      current_line = current_line .. (current_line == "" and "" or " ") .. word
    end
  end

  if current_line ~= "" then table.insert(lines, current_line) end
  return lines
end

---@param diagnostic vim.Diagnostic
local function virtual_lines_format(diagnostic)
  local win = buf_to_win(diagnostic.bufnr or 0)
  local sign_column_width = vim.fn.getwininfo(win)[1].textoff
  local text_area_width = vim.api.nvim_win_get_width(win) - sign_column_width
  local center_width = 5
  local left_width = 1

  ---@type string[]
  local lines = {}
  for msg_line in diagnostic.message:gmatch("([^\n]+)") do
    local max_width = text_area_width - diagnostic.col - center_width - left_width
    vim.list_extend(lines, split_line(msg_line, max_width))
  end

  return table.concat(lines, "\n")
end

---@param diagnostic vim.Diagnostic
local function virtual_text_format(diagnostic)
  local ft = vim.bo[diagnostic.bufnr or 0].filetype
  -- Possible symbols = ■   󰨓 󱓻 󰝤
  if ft == "lazy" then return ("󱓻 %s "):format(diagnostic.message) end

  -- Don't show the virtual text of the current line, we're using virtual lines instead
  if vim.fn.line(".") == diagnostic.lnum + 1 then return nil end

  -- Shorter names for some sources
  -- Taken from https://github.com/MariaSolOs/dotfiles/blob/8cdc092c0c340f669bef33a932f235dcde3c2019/.config/nvim/lua/lsp.lua#L153
  local special_sources = {
    ["Lua Diagnostics."] = "lua",
    ["Lua Syntax Check."] = "lua",
  }

  local severity = vim.diagnostic.severity[diagnostic.severity]
  local message = Defaults.icons.diagnostics[severity]
  if diagnostic.source then
    local source = special_sources[diagnostic.source] or diagnostic.source
    message = ("%s%s "):format(message, source)
  end

  if diagnostic.code then
    message = ("%s[%s] "):format(message, special_sources[diagnostic.code] or diagnostic.code)
  else
    message = ("%s: %s "):format(message, diagnostic.message)
  end

  return message
end

M._did_setup = false
M.setup = function()
  M._did_setup = true

  -- Override the virtual text diagnostic handler so that the most severe diagnostic is shown first.
  -- Taken from https://github.com/MariaSolOs/dotfiles/blob/8cdc092c0c340f669bef33a932f235dcde3c2019/.config/nvim/lua/lsp.lua#L185
  local show_handler = assert(vim.diagnostic.handlers.virtual_text.show)
  local hide_handler = vim.diagnostic.handlers.virtual_text.hide

  vim.diagnostic.handlers.virtual_text = {
    show = function(ns, bufnr, diagnostics, opts)
      table.sort(diagnostics, function(diag1, diag2) return diag1.severity > diag2.severity end)
      return show_handler(ns, bufnr, diagnostics, opts)
    end,
    hide = hide_handler,
  }

  ---@type vim.diagnostic.Opts
  local diag_opts = {
    signs = {
      -- stylua: ignore
      text = {
        [vim.diagnostic.severity.ERROR] = Defaults.icons.diagnostics.ERROR,
        [vim.diagnostic.severity.WARN]  = Defaults.icons.diagnostics.WARN,
        [vim.diagnostic.severity.INFO]  = Defaults.icons.diagnostics.INFO,
        [vim.diagnostic.severity.HINT]  = Defaults.icons.diagnostics.HINT,
      },
    },
    underline = true,
    update_in_insert = false,
    virtual_text = {
      prefix = "",
      spacing = 0,
      format = virtual_text_format,
    },
    virtual_lines = {
      current_line = true,
      format = virtual_lines_format,
    },
  }

  vim.diagnostic.config(diag_opts)

  -- Re-draw diagnostics each line change to account for virtual_text changes
  local _last_line = vim.fn.getpos(".")
  vim.api.nvim_create_autocmd("CursorMoved", {
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if ft == "lazy" then return end

      local current_line = vim.fn.getpos(".")

      if current_line ~= _last_line then
        vim.diagnostic.hide(nil, args.buf)
        vim.diagnostic.show(nil, args.buf)
      end

      _last_line = current_line
    end,
  })

  -- Re-render diagnostics when the window is resized or when the diagnostics change
  vim.api.nvim_create_autocmd({ "VimResized", "DiagnosticChanged" }, {
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if ft == "lazy" then return end

      vim.diagnostic.hide(nil, args.buf)
      vim.diagnostic.show(nil, args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "n:i",
    callback = function(args) vim.diagnostic.hide(nil, args.buf) end,
  })
end

return M
