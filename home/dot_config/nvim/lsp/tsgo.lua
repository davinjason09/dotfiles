---@type vim.lsp.Config
return {
  cmd = { "tsgo", "--lsp", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = function(buf, on_dir)
    local root_markers = {
      { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" },
      { ".git" },
    }

    if vim.fs.root(buf, { "deno.json", "deno.jsonc", "deno.lock" }) then return end

    local project_root = vim.fs.root(buf, root_markers) or vim.fn.getcwd()

    on_dir(project_root)
  end,
}
