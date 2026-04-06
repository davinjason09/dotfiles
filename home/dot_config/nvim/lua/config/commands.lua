vim.api.nvim_create_user_command(
  "LspInfo",
  function() vim.cmd("silent! checkhealth vim.lsp") end,
  { desc = "Language Server Info" }
)

vim.api.nvim_create_user_command(
  "LspLog",
  function()
    Snacks.win({
      file = vim.lsp.log.get_filename(),
      border = "rounded",
    }):set_title("LSP Log", "center")
  end,
  { desc = "LSP Log" }
)

vim.api.nvim_create_user_command(
  "News",
  function()
    Snacks.win({
      style = "small_float",
      file = vim.fs.joinpath(vim.env.VIMRUNTIME, "doc", "news.txt"),
      border = "rounded",
    }):set_title("Neovim News", "center")
  end,
  { desc = "Neovim News" }
)

vim.api.nvim_create_user_command("TermToggle", function()
  Snacks.picker.terminal() ---@diagnostic disable-line: undefined-field
end, { desc = "Toggle Terminal" })
