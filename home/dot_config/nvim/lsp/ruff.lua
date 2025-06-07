---@type vim.lsp.Config
return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = {
    ".git",
    ".ruff.toml",
    "Pipfile",
    "pyproject.toml",
    "pyrightconfig.json",
    "requirements.txt",
    "setup.cfg",
    "setup.py",
    "ruff.toml",
    "uv.lock",
  },
  capabilities = {
    hoverProvider = false,
  },
}
