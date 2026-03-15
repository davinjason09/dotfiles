---@type vim.lsp.Config
return {
  cmd = { "harper-ls", "--stdio" },
  auto_attach = function() return vim.o.spell end,
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
