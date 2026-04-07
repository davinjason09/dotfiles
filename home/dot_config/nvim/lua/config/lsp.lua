-- Set up LSP keymaps and for the current buffer
---@param client vim.lsp.Client
---@param buf integer
local function on_attach(client, buf)
  ---@param lhs string
  ---@param rhs string|function
  ---@param desc string
  ---@param mode? string|string[]
  local function map(lhs, rhs, desc, mode) vim.keymap.set(mode or "n", lhs, rhs, { buffer = buf, desc = desc }) end

  -- stylua: ignore start
  map("gs", function() Snacks.picker.lsp_symbols() end,         "[G]oto [S]ymbol")
  map("gr", function() Snacks.picker.lsp_references() end,      "[G]oto [R]eferences")
  map("gd", function() Snacks.picker.lsp_definitions() end,     "[G]oto [D]efinition")
  map("gi", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
  map("gD", function() Snacks.picker.lsp_declarations() end,    "[G]oto [D]eclaration")
  map("gO", function() vim.lsp.buf.document_symbol() end,       "[G]oto [O]utline")
  -- stylua: ignore end

  -- stylua: ignore start
  ---@diagnostic disable: undefined-field
  map("<leader>ca", function() Snacks.picker.code_action({ all = true }) end,           "[C]ode: [A]ction", { "n" })
  map("<leader>ca", function() Snacks.picker.code_action({ mode = vim.fn.mode() }) end, "[C]ode: [A]ction", { "x" })
  ---@diagnostic enable: undefined-field
  map("<leader>cr", function() vim.lsp.buf.rename() end,               "[C]ode: [R]ename (Symbol)")
  map("<leader>cR", function() Snacks.rename.rename_file() end,        "[C]ode: [R]ename (File)")
  map("<leader>cd", function() Snacks.picker.diagnostics_buffer() end, "[C]ode: [D]iagnostics")
  -- stylua: ignore end

  map("K", function() vim.lsp.buf.hover() end, "Hover Documentation")

  if Snacks.words.is_enabled() and client.server_capabilities.documentHighlightProvider then
    map("]]", function() Snacks.words.jump(vim.v.count1, true) end, "Next Reference")
    map("[[", function() Snacks.words.jump(-vim.v.count1, true) end, "Previous Reference")
  end

  -- NOTE:
  -- Most color swatched is handled by "eero-lehtinen/oklch-color-picker.nvim" as not all LSP implements
  -- textDocument/documentColor. So we only enable this as long as `vim.lsp.document_color` is enabled
  -- in the current buffer, and let "eero-lehtinen/oklch-color-picker.nvim" handle it
  if client:supports_method("textDocument/documentColor") then
    -- Defer 100ms because a race condition is possible between this autocmd with the plugin's autocmd
    vim.defer_fn(function()
      local is_enabled = vim.lsp.document_color.is_enabled({ bufnr = buf })
      vim.lsp.document_color.enable(is_enabled, { bufnr = buf }, { style = "󱓻 " })
    end, 10)
  end

  if client:supports_method("textDocument/inlineCompletion") then
    vim.lsp.inline_completion.enable(true, { bufnr = buf })
  end

  if client:supports_method("textDocument/inlayHint") then
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      Snacks.toggle.inlay_hints():map("<leader>uh")
    end
  end

  if client:supports_method("textDocument/signatureHelp") then
    map("<C-k>", function()
      local blink = require("blink.cmp")

      if blink.is_signature_visible() then blink.hide_signature() end
      vim.lsp.buf.signature_help(Defaults.hover_opts --[[@as vim.lsp.buf.signature_help.Opts]])
    end, "Signature Help", "i")
  end

  if client:supports_method("textDocument/foldingRange") then
    vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local" })
    vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.lsp.foldexpr()", { scope = "local" })
  end
end

-- Override default LSP hover and signature help to use a custom border and max size
local hover = vim.lsp.buf.hover

vim.lsp.buf.hover = function()
  local method = "textDocument/hover" ---@type vim.lsp.protocol.Methods
  local ok, client = pcall(vim.lsp.get_clients, { bufnr = 0, method = method })
  if not ok then
    return vim.notify(("No client in this buffer supports %s"):format(method), vim.log.levels.WARN, { title = "LSP" })
  end

  local opts = Defaults.hover_opts --[[@as vim.lsp.buf.hover.Opts]]
  local ft = vim.bo[0].filetype
  local ft_icon, color = Snacks.util.icon(ft, "filetype")

  opts.title = {
    { "╼ ", "LSPHoverBorder" },
    { ft_icon, color },
    { client[1].name or "LSP", "@text" },
    { " ╾", "LSPHoverBorder" },
  }
  opts.title_pos = "right"
  return hover(opts)
end

local register_capability = vim.lsp.handlers["client/registerCapability"]
vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
  local ok, client = pcall(vim.lsp.get_client_by_id, ctx.client_id)
  if not ok then
    return vim.notify(("Client with id %s not found"):format(ctx.client_id), vim.log.levels.ERROR, { title = "LSP" })
  end

  on_attach(client, vim.api.nvim_get_current_buf())

  return register_capability(err, res, ctx)
end

-- Set up LSP servers.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    local server_configs = vim
      .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
      :map(function(file) return vim.fn.fnamemodify(file, ":t:r") end)
      :filter(function(lsp)
        local settings = vim.lsp.config[lsp]
        local auto_attach = type(settings.auto_attach) == "function" and settings.auto_attach() or settings.auto_attach
        return settings.enabled ~= false and auto_attach ~= false
      end)
      :totable()
    vim.lsp.enable(server_configs)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local ok, client = pcall(vim.lsp.get_client_by_id, ev.data.client_id)
    if not ok then
      return vim.notify(
        ("Client with id %s not found"):format(ev.data.client_id),
        vim.log.levels.ERROR,
        { title = "LSP" }
      )
    end

    on_attach(client, ev.buf)

    require("custom.lsp.diagnostic").setup()
  end,
  desc = "LSP Keymaps",
})
