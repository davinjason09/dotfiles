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

  map("<leader>ca", require("tiny-code-action").code_action, "[C]ode: [A]ction", { "n", "v" })
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

  Snacks.util.lsp.on({ method = ms.textDocument_foldingRange }, function()
    vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local" })
    vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.lsp.foldexpr()", { scope = "local" })
  end)
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
    { client.name or "LSP", "@text" },
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

        if first_line:match("^%-%-%s*disable") then return end
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

    require("custom.lsp.diagnostic").setup()
  end,
  desc = "LSP Keymaps",
})
