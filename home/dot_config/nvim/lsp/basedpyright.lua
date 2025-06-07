---@type vim.lsp.Config
return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    ".git",
    "Pipfile",
    "pyproject.toml",
    "pyrightconfig.json",
    "requirements.txt",
    "setup.cfg",
    "setup.py",
  },
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        reportMissingTypeStubs = false,
        typeCheckingMode = "off",
        useLibraryCodeForTypes = true,
      },
      capabilities = {
        textDocument = {
          publishDiagnostics = {
            tagSupport = {
              valueSet = { 2 },
            },
          },
        },
      },
    },
  },
  capabilities = {
    textDocument = {
      publishDiagnostics = {
        tagSupport = {
          valueSet = { 2 },
        },
      },
    },
  },
}
