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
  local cur_line = ""

  for word in string.gmatch(str, "%S+") do
    if #cur_line + #word + 1 > max_width then
      table.insert(lines, cur_line)
      cur_line = word
    else
      cur_line = (cur_line ~= "" and cur_line .. " " or "") .. word
    end
  end

  if cur_line ~= "" then table.insert(lines, cur_line) end
  return lines
end

---@param diagnostic vim.Diagnostic
local function virtual_lines_format(diagnostic)
  local buf = diagnostic.bufnr or vim.api.nvim_get_current_buf()
  local win = buf_to_win(buf)
  local win_info = vim.fn.getwininfo(win)

  local sign_column_width = #win_info > 0 and win_info[1].textoff or 8
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
  if M._did_setup then return true end
  M._did_setup = true

  -- Override the virtual text diagnostic handler so that the most severe diagnostic is shown first.
  -- Taken from https://github.com/MariaSolOs/dotfiles/blob/8cdc092c0c340f669bef33a932f235dcde3c2019/.config/nvim/lua/lsp.lua#L185

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
    severity_sort = true,
  }

  vim.diagnostic.config(diag_opts)

  -- Re-draw diagnostics each line change to account for virtual_text changes
  local last_line = vim.fn.line(".")
  local timer = nil ---@type uv_timer_t?
  local debounce = 100

  vim.api.nvim_create_autocmd("CursorMoved", {
    callback = function(args)
      if vim.bo[args.buf].filetype == "lazy" then return end

      local cur_line = vim.fn.line(".")

      if cur_line ~= last_line then
        if timer then timer:stop() end

        timer = vim.defer_fn(function()
          pcall(vim.diagnostic.hide, nil, args.buf)
          pcall(vim.diagnostic.show, nil, args.buf)
          last_line = cur_line
        end, debounce)
      end
    end,
  })

  -- Re-render diagnostics when the window is resized or when the diagnostics change
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function(args)
      if vim.bo[args.buf].filetype == "lazy" then return end

      pcall(vim.diagnostic.hide, nil, args.buf)
      pcall(vim.diagnostic.show, nil, args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "n:i",
    callback = function(args) pcall(vim.diagnostic.hide, nil, args.buf) end,
  })
end

return M
