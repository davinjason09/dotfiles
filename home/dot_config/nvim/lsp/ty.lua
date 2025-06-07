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
  init_options = {
    settings = {
      experimental = {
        completions = { enable = false },
      },
    },
  },
}
