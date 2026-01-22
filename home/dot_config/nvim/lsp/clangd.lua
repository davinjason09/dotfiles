---@param bufnr integer
---@param client vim.lsp.Client
local function switch_source_header(bufnr, client)
  local method_name = "textDocument/switchSourceHeader"
  if not client or not client:supports_method(method_name) then
    return vim.notify(("Method %s is not supported by any servers active on the current buffer"):format(method_name))
  end

  local params = vim.lsp.util.make_text_document_params(bufnr)
  client:request(method_name, params, function(err, result)
    if err then error(tostring(err)) end
    if not result then return vim.notify("Corresponding file cannot be determined") end

    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

---@param bufnr integer
---@param client vim.lsp.Client
local function symbol_info(bufnr, client)
  local method_name = "textDocument/symbolInfo"

  if not client or not client:supports_method(method_name) then
    return vim.notify("Clangd client not found", vim.log.levels.ERROR)
  end

  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  client:request(method_name, params, function(err, res)
    if err or #res == 0 then return end

    local container = string.format("container: %s", res[1].containerName) ---@type string
    local name = string.format("name: %s", res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, "", {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = "Symbol Info",
    })
  end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--all-scopes-completion",
    "--suggest-missing-includes",
    "--offset-encoding=utf-16",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    ".git",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    "Makefile",
    "build.ninja",
    "meson.build",
  },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  ---@param init_result ClangdInitializeResult
  on_init = function(client, init_result)
    if init_result.offsetEncoding then client.offset_encoding = init_result.offsetEncoding end
  end,
  -- stylua: ignore
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "ClangdSwitchSourceHeader", function()
      switch_source_header(bufnr, client)
    end, { desc = "Switch between source/header" })

    vim.api.nvim_buf_create_user_command( bufnr, "ClangdShowSymbolInfo", function()
      symbol_info(bufnr, client)
    end, { desc = "Show symbol info" })

    local function map(lhs, rhs, desc, mode)
      vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("<leader>ch", "<CMD>ClangdSwitchSourceHeader<CR>", "[C]ode: Switch Source/[H]eader")
    map("<leader>ci", "<CMD>ClangdShowSymbolInfo<CR",      "[C]ode: Show Symbol [I]nfo")
  end,
}
