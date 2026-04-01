vim.api.nvim_create_user_command(
  "LspInfo",
  function() vim.cmd("silent! checkhealth vim.lsp") end,
  { desc = "Language Server Info" }
)

vim.api.nvim_create_user_command(
  "LspLog",
  function()
    Snacks.win({
      file = vim.lsp.get_log_path(),
      border = "rounded",
    }):set_title("LSP Log", "center")
  end,
  { desc = "LSP Log" }
)


vim.api.nvim_create_user_command("TermToggle", function()
  local picker = Snacks.picker.get()[1]
  if picker then
    picker:close()
    vim.schedule(Utils.edit.escape)
  else
    require("custom.terminal").open()
  end
end, { desc = "Toggle Terminal" })
