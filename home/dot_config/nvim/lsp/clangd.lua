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
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    "Makefile",
    "build.ninja",
    "meson.build",
  },
  init_options = {
    clangdFileStatus = true,
    usePlaceholders = true,
    completeUnimported = true,
    semanticHighlighting = true,
  },
  -- stylua: ignore
  on_attach = function(_, bufnr)
    local map = vim.keymap.set
    map("n", "<leader>ch", "<CMD>ClangdSwitchSourceHeader<CR>", { buffer = bufnr, desc = "[C]ode: Switch Source/[H]eader" })
    map("n", "<leader>ct", "<CMD>ClangdTypeHierarchy<CR>", { buffer = bufnr, desc = "[C]ode: Show [T]ype Hierarchy" })
    map("n", "<leader>ci", "<CMD>ClangdSymbolInfo<CR>", { buffer = bufnr, desc = "[C]ode: Show [T]ype Hierarchy" })
    map("n", "<leader>cm", "<CMD>ClangdMemoryUsage<CR>", { buffer = bufnr, desc = "[C]ode: Show [M]emory Usage" })
    map({ "n", "v" }, "<leader>cA", "<cmd>ClangAST<CR>", { buffer = bufnr, desc = "[C]ode: Show [A]ST" })
  end,
  settings = {
    clangd = {
      semanticHighlighting = true,
      single_file_support = false,
    },
  },
  single_file_support = true,
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
}
