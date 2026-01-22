-- https://github.com/neovim/nvim-lspconfig/blob/master/plugin/lspconfig.lua
local function complete_clients(args)
  return vim
    .iter(vim.lsp.get_clients())
    :map(function(client) return client.name end)
    :filter(function(name) return name:sub(1, #args) == args end)
    :totable()
end

local function complete_configs(args)
  return vim
    .iter(vim.api.nvim_get_runtime_file(("lsp/%s*.lua"):format(args), true))
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
    for name, _ in pairs(vim.lsp._enabled_configs) do
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
      .iter(vim.lsp.get_clients())
      :map(function(client)
        if client.name ~= "copilot" then return client.name end
      end)
      :totable()
  end

  for name in vim.iter(clients) do
    if vim.lsp.config[name] == nil then
      vim.notify(("Invalid LSP client name: %s"):format(name), "warn", { title = "LSP" })
    else
      vim.lsp.enable(name, false)
      if ctx.bang then vim.iter(vim.lsp.get_clients({ name = name })):each(function(client) client:stop(true) end) end
    end
  end
end, {
  desc = "Disable and stop the given LSP client(s)",
  nargs = "?",
  bang = true,
  complete = complete_clients,
})

vim.api.nvim_create_user_command("LspRestart", function(ctx)
  local clients = ctx.fargs

  if #clients == 0 then
    clients = vim
      .iter(vim.lsp.get_clients())
      :map(function(client)
        if client.name ~= "copilot" then return client.name end
      end)
      :totable()
  end

  for name in vim.iter(clients) do
    if vim.lsp.config[name] == nil then
      vim.notify(("Invalid LSP client name: %s"):format(name), "warn", { title = "LSP" })
    else
      vim.lsp.enable(name, false)
      if ctx.bang then vim.iter(vim.lsp.get_clients({ name = name })):each(function(client) client:stop(true) end) end
    end
  end

  local timer = assert(vim.uv.new_timer())
  timer:start(500, 0, function()
    for name in vim.iter(clients) do
      vim.schedule_wrap(vim.lsp.enable)(name)
    end
  end)
end, {
  desc = "Restart the given LSP client(s)",
  nargs = "?",
  bang = true,
  complete = complete_clients,
})

vim.api.nvim_create_user_command("TermToggle", function()
  local picker = Snacks.picker.get()[1]
  if picker then
    picker:close()
    vim.schedule(Utils.edit.escape)
  else
    require("custom.terminal").open()
  end
end, { desc = "Toggle Terminal" })
