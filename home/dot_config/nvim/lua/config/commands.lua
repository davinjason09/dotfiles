-- https://github.com/neovim/nvim-lspconfig/blob/a182334ba933e58240c2c45e6ae2d9c7ae313e00/plugin/lspconfig.lua#L76

local function complete_clients(arg)
  return vim
    .iter(vim.lsp.get_clients())
    :map(function(client) return client.name end)
    :filter(function(name) return name:sub(1, #arg) == arg end)
    :totable()
end

local function complete_configs(arg)
  return vim
    .iter(vim.api.nvim_get_runtime_file(("lsp/%s*.lua"):format(arg), true))
    :map(function(path)
      local file_name = path:match("[^/]*.lua$")
      return file_name:sub(0, #file_name - 4)
    end)
    :totable()
end

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

vim.api.nvim_create_user_command("LspStart", function(ctx)
  local servers = ctx.fargs

  if #servers == 0 then
    local ft = vim.bo.filetype
    ---@diagnostic disable-next-line: invisible
    for name, _ in pairs(vim.lsp.config._configs) do
      local fts = vim.lsp.config[name].filetypes
      if fts and vim.tbl_contains(fts, ft) then table.insert(servers, name) end
    end
  end

  vim.lsp.enable(servers)
end, {
  desc = "Enable and launch LSP client(s)",
  nargs = "?",
  complete = complete_configs,
})

vim.api.nvim_create_user_command("LspStop", function(ctx)
  local clients = ctx.fargs

  if #clients == 0 then
    clients = vim
      .iter(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }))
      :map(function(client)
        if client.name ~= "copilot" then return client.name end
      end)
      :totable()
  end

  for _, name in ipairs(clients) do
    if vim.lsp.config[name] == nil then
      vim.notify(("Invalid LSP client name: %s"):format(name), "warn", { title = "LSP" })
    else
      vim.lsp.enable(name, false)
    end
  end
end, {
  desc = "Disable and stop the given LSP client(s)",
  nargs = "?",
  complete = complete_clients,
})

vim.api.nvim_create_user_command("LspRestart", function(ctx)
  for _, name in ipairs(ctx.fargs) do
    if vim.lsp.config[name] == nil then
      vim.notify(("Invalid LSP client name: %s"):format(name), "warn", { title = "LSP" })
    else
      vim.lsp.enable(name, false)
    end
  end

  local timer = assert(vim.uv.new_timer())
  timer:start(500, 0, function()
    for _, name in ipairs(ctx.fargs) do
      vim.schedule_wrap(function(x) vim.lsp.enable(x) end)(name)
    end
  end)
end, {
  desc = "Restart the given LSP client(s)",
  nargs = "+",
  complete = complete_clients,
})
