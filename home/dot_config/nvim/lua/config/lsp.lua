-- ╭─────────────────────────────────────────────────────────╮
-- │                           LSP                           │
-- ╰─────────────────────────────────────────────────────────╯

local methods = vim.lsp.protocol.Methods

-- Set up LSP keymaps and for the current buffer
---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
  ---@param lhs string
  ---@param rhs string|function
  ---@param desc string
  ---@param mode? string|string[]
  local function map(lhs, rhs, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("gs", Snacks.picker.lsp_symbols, "[G]oto [S]ymbol")
  map("gr", Snacks.picker.lsp_references, "[G]oto [R]eferences")
  map("gd", Snacks.picker.lsp_definitions, "[G]oto [D]efinition")
  map("gi", Snacks.picker.lsp_implementations, "[G]oto [I]mplementation")
  map("gD", Snacks.picker.lsp_declarations, "[G]oto [D]eclaration")
  map("gO", vim.lsp.buf.document_symbol, "[G]oto [O]utline")

  map("<leader>ca", vim.lsp.buf.code_action, "[C]ode: [A]ction", { "n", "v" })
  map("<leader>cr", vim.lsp.buf.rename, "[C]ode: [R]ename (Symbol)")
  map("<leader>cR", Snacks.rename.rename_file, "[C]ode: [R]ename (File)")
  map("<leader>cd", Snacks.picker.diagnostics_buffer, "[C]ode: [D]iagnostics")

  map("K", function() vim.lsp.buf.hover() end, "Hover Documentation")

  if Snacks.words.is_enabled() and client.server_capabilities.documentHighlightProvider then
    map("]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference")
    map("[[", function() Snacks.words.jump(-vim.v.count1) end, "Previous Reference")
  end

  if client:supports_method(methods.textDocument_inlayHint) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    Snacks.toggle.inlay_hints():map("<leader>uh")
  end

  if client:supports_method(methods.textDocument_signatureHelp) then
    local blink_window = Utils.lazy_require("blink.cmp.completion.windows.menu")
    local blink = Utils.lazy_require("blink.cmp")

    map("<C-k>", function()
      if blink_window.win:is_open() then blink.hide() end
      vim.lsp.buf.signature_help()
    end, "Signature Help", "i")
  end
end

-- Override default LSP hover and signature help to use a custom border and max size
---@diagnostic disable: duplicate-set-field
local hover = vim.lsp.buf.hover
local signature_help = vim.lsp.buf.signature_help

vim.lsp.buf.hover = function()
  local client = assert(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })[1])
  local opts = Defaults.hover_opts --[[@as vim.lsp.buf.hover.Opts]]
  local ft = vim.bo[0].filetype
  local ft_icon, color = Snacks.util.icon(ft, "filetype")

  opts.title = {
    { "╼ ", "LSPHoverBorder" },
    { ft_icon, color },
    { " " .. (client.name or "LSP"), "@text" },
    { " ╾", "LSPHoverBorder" },
  }
  opts.title_pos = "right"
  return hover(opts)
end
vim.lsp.buf.signature_help = function()
  return signature_help(Defaults.hover_opts --[[@as vim.lsp.buf.signature_help.Opts]])
end

---@diagnostic enable: duplicate-set-field

local register_capability = vim.lsp.handlers[methods.client_registerCapability]
vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
  local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

  on_attach(client, vim.api.nvim_get_current_buf())

  return register_capability(err, res, ctx)
end

-- Set up LSP servers.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    local server_configs = vim
      .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
      :map(function(file)
        -- Disable lsp if the first line starts with `-- disable`
        local first_line = vim.fn.readfile(file, "", 1)[1] or ""

        if first_line:match("^%-%- disable") then return end
        return vim.fn.fnamemodify(file, ":t:r")
      end)
      :totable()
    vim.lsp.enable(server_configs)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client.name == "copilot" then return end

    on_attach(client, args.buf)
  end,
  desc = "LSP Keymaps",
})

-- ╭─────────────────────────────────────────────────────────╮
-- │                       Diagnostics                       │
-- ╰─────────────────────────────────────────────────────────╯

-- Use virtual_lines for the current line diagnstics and use virtual_text for the rest
-- Taken from https://github.com/joe-p/kickstart.nvim/blob/4f756cf63ec2d4eea293918e086096ff984eebc9/lua/joe-p/diagnostic.lua

-- Get the window id of a buffer
---@param bufnr integer
local function buf_to_win(bufnr)
  local current_win = vim.fn.win_getid()

  -- Check if the current window has the buffer
  if vim.fn.winbufnr(current_win) == bufnr then return current_win end

  -- Else, find a visible windows with this buffer
  local win_ids = vim.fn.win_findbuf(bufnr)
  local current_tabpage = vim.fn.tabpagenr()

  for _, win_id in ipairs(win_ids) do
    if vim.fn.win_id2tabwin(win_id)[1] == current_tabpage then return win_id end
  end

  return current_win
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
  local win = buf_to_win(diagnostic.bufnr)
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
  local ft = vim.bo[diagnostic.bufnr].filetype
  -- Possible sumbols = ■   󰨓 󱓻 󰝤
  if ft == "lazy" or ft == "mason" then return ("󱓻 %s "):format(diagnostic.message) end

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
    message = string.format("%s%s", message, source)
  end

  if diagnostic.code then
    message = string.format("%s[%s]", message, special_sources[diagnostic.code] or diagnostic.code)
  else
    message = string.format("%s: %s", message, diagnostic.message)
  end

  return message .. " "
end

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

local opts = Defaults.diagnostics
opts.virtual_lines.format = virtual_lines_format
opts.virtual_text.format = virtual_text_format

vim.diagnostic.config(opts)

-- Re-draw diagnostics each line change to account for virtual_text changes
local last_line = vim.fn.getpos(".")
vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "lazy" or ft == "mason" then return end

    local current_line = vim.fn.getpos(".")

    if current_line ~= last_line then
      vim.diagnostic.hide(nil, args.buf)
      vim.diagnostic.show(nil, args.buf)
    end

    last_line = current_line
  end,
})

-- Re-render diagnostics when the window is resized or when the diagnostics change
vim.api.nvim_create_autocmd({ "VimResized", "DiagnosticChanged" }, {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "lazy" or ft == "mason" then return end

    vim.diagnostic.hide(nil, args.buf)
    vim.diagnostic.show(nil, args.buf)
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "n:i",
  callback = function(args) vim.diagnostic.hide(nil, args.buf) end,
})
