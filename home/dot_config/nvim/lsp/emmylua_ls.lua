---@type vim.lsp.Config
return {
  cmd = { "emmylua_ls" },
  filetypes = { "lua" },
  root_markers = {
    ".emmyrc.json",
    ".luacheckrc",
    ".luarc.json",
    ".stylua.toml",
    "lazy-lock.json",
    "stylua.toml",
    "lua/",
  },
  workspace_required = false,
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
