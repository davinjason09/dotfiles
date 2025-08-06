---@type vim.lsp.Config
return {
  cmd = { "ty", "server" },
  filetypes = { "python" },
  root_markers = {
    ".git",
    "Pipfile",
    "pyproject.toml",
    "pyrightconfig.json",
    "requirements.txt",
    "setup.cfg",
    "setup.py",
    "ty.toml",
    "uv.lock",
  },
  on_attach = function(client)
    client.server_capabilities.inlayHintProvider = false
    client.server_capabilities.hoverProvider = false
  end,
}
