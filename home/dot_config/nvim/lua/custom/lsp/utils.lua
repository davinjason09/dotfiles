local M = {}

local ms = vim.lsp.protocol.Methods
M.code_action = {}

---@param root_dir string
M.get_typescript_server_path = function(root_dir)
  local project_roots = vim.fs.find("node_modules", { path = root_dir, upward = true, limit = math.huge })

  for _, project_root in ipairs(project_roots) do
    local typescript_path = project_root .. "/typescript"
    local stat = vim.uv.fs_stat(typescript_path)
    if stat and stat.type == "directory" then return typescript_path .. "/lib" end
  end

  return ""
end

---@param buf integer
---@param client vim.lsp.Client
---@param range? integer[]
---@return table
M.get_line_diagnostics = function(buf, client, range)
  local lnum = not range and (vim.api.nvim_win_get_cursor(0)[1] - 1) or nil

  local diagnostics = vim.diagnostic.get(buf, { lnum = lnum })
  if #diagnostics == 0 then return {} end

  local lsp_diags = {}
  for _, diag in ipairs(diagnostics) do
    local is_client_diag = diag.namespace == vim.lsp.diagnostic.get_namespace(client.id)
      or (diag.user_data and diag.user_data.lsp)

    if is_client_diag then
      local in_range = not range or (diag.lnum >= range[1] and diag.lnum <= range[2])
      if in_range and diag.user_data and diag.user_data.lsp then table.insert(lsp_diags, diag.user_data.lsp) end
    end
  end

  table.sort(lsp_diags, function(a, b) return a.range.start.line < b.range.start.line end)

  return lsp_diags
end

---@param action? lsp.CodeAction
---@param client vim.lsp.Client
---@param ctx lsp.CodeActionContext
---@param bufnr? integer
local function apply(action, client, ctx, bufnr)
  if action == nil then return vim.notify("Error: No action to apply/action can't be applied", vim.log.levels.ERROR) end

  ctx = ctx or {}

  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    local win = vim.fn.bufwinid(bufnr)
    if win ~= -1 then vim.api.nvim_set_current_win(win) end
  end

  if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding) end

  local action_cmd = action.command
  if not action_cmd then return end

  local command = type(action_cmd) == "table" and action_cmd or action
  client:exec_cmd(command, ctx)
end

---@param action lsp.CodeAction
---@param client vim.lsp.Client
---@param ctx lsp.CodeActionContext
---@param bufnr integer
---@param resolved_from_preview? boolean
M.code_action.apply_action = function(action, client, ctx, bufnr, resolved_from_preview)
  if not client then return end
  if resolved_from_preview then return apply(action, client, ctx, bufnr) end

  local dyn_cap = client.dynamic_capabilities
  local reg = dyn_cap and dyn_cap:get(ms.textDocument_codeAction, { bufnr = bufnr }) or {}
  local support_resolve = vim.tbl_get(reg, "registerOptions", "resolveProvider")
    or client:supports_method(ms.codeAction_resolve)

  if action.edit == nil and client and support_resolve then
    client:request(ms.codeAction_resolve, action, function(err, resolved_action)
      if err and not action.command then
        return vim.notify("Error resolving action: " .. (err.message or "unknown error"), vim.log.levels.ERROR)
      end

      apply(resolved_action or action, client, ctx, bufnr)
    end, bufnr)
  else
    apply(action, client, ctx, bufnr)
  end
end

return M
