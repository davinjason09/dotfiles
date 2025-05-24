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

vim.api.nvim_create_user_command(
  "LspStart",
  function() vim.cmd.e() end,
  { desc = "Starts LSP clients in the current buffer " }
)

vim.api.nvim_create_user_command("LspStop", function(ctx)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if ctx.args == "" or ctx.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ": stopped", vim.log.levels.INFO, { title = "LSP" })
    end
  end
end, {
  desc = "Stop all LSP clients or a specific client attached to the current buffer",
  nargs = "?",
  complete = Utils.get_lsp_clients,
})

vim.api.nvim_create_user_command("LspRestart", function(ctx)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  for _, client in ipairs(clients) do
    if ctx.args == "" and client.name ~= "copilot" or ctx.args == client.name then
      vim.api.nvim_create_autocmd("LspDetach", {
        once = true,
        callback = function(args)
          if args.data and args.data.client_id == client.id then
            vim.notify("Restarting " .. client.name, vim.log.levels.INFO, { title = "LSP" })
            vim.lsp.start(vim.lsp.config[client.name], {
              bufnr = bufnr,
              reuse_client = function() return false end,
            })
          end
        end,
      })

      vim.cmd("LspStop " .. client.name)
    end
  end

  vim.defer_fn(function() vim.cmd.e() end, 500)
end, {
  desc = "Restart all LSP clients or a specific client attached to the current buffer",
  nargs = "?",
  complete = Utils.get_lsp_clients,
})
