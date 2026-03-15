---@type vim.lsp.Config
return {
  cmd = { "taplo", "lsp", "stdio" },
  enabled = false,
  filetypes = { "toml" },
  root_markers = { ".git" },
}
