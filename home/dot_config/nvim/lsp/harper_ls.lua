---@type vim.lsp.Config
return {
  cmd = { "harper-ls", "--stdio" },
  filetypes = { "typst" },
  root_markers = { ".harper-dictionary.txt", ".git" },
  settings = {
    ["harper-ls"] = {
      linters = {
        SentenceCapitalization = false,
        SpellCheck = false,
      },
    },
  },
}
