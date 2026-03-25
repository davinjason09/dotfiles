---@type vim.lsp.Config
return {
  cmd = { "nu", "--lsp" },
  filetypes = { "nu" },
  root_dir = function(buf, on_dir)
    on_dir(vim.fs.root(buf, { ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(buf)))
  end,
}
