local ms = vim.lsp.protocol.Methods

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

  map("gs", function() Snacks.picker.lsp_symbols() end, "[G]oto [S]ymbol")
  map("gr", function() Snacks.picker.lsp_references() end, "[G]oto [R]eferences")
  map("gd", function() Snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")
  map("gi", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
  map("gD", function() Snacks.picker.lsp_declarations() end, "[G]oto [D]eclaration")
  map("gO", vim.lsp.buf.document_symbol, "[G]oto [O]utline")

  map("<leader>ca", require("tiny-code-action").code_action, "[C]ode: [A]ction", { "n", "v" })
  map("<leader>cr", vim.lsp.buf.rename, "[C]ode: [R]ename (Symbol)")
  map("<leader>cR", Snacks.rename.rename_file, "[C]ode: [R]ename (File)")
  map("<leader>cd", Snacks.picker.diagnostics_buffer, "[C]ode: [D]iagnostics")

  map("K", function() vim.lsp.buf.hover() end, "Hover Documentation")

  if Snacks.words.is_enabled() and client.server_capabilities.documentHighlightProvider then
    map("]]", function() Snacks.words.jump(vim.v.count1, true) end, "Next Reference")
    map("[[", function() Snacks.words.jump(-vim.v.count1, true) end, "Previous Reference")
  end

  Snacks.util.lsp.on({ method = ms.textDocument_inlayHint }, function(buf)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      Snacks.toggle.inlay_hints():map("<leader>uh")
    end
  end)

  if client:supports_method(ms.textDocument_signatureHelp) then
    local blink = Utils.lazy_require("blink.cmp")

    map("<C-k>", function()
      if blink.is_signature_visible() then blink.hide_signature() end
      vim.lsp.buf.signature_help(Defaults.hover_opts --[[@as vim.lsp.buf.signature_help.Opts]])
    end, "Signature Help", "i")
  end

  Snacks.util.lsp.on({ method = ms.textDocument_foldingRange }, function()
    vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local" })
    vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.lsp.foldexpr()", { scope = "local" })
  end)
end

-- Override default LSP hover and signature help to use a custom border and max size
local hover = vim.lsp.buf.hover

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

local register_capability = vim.lsp.handlers[ms.client_registerCapability]
vim.lsp.handlers[ms.client_registerCapability] = function(err, res, ctx)
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
