---@param command_name string
---@return fun():nil run_tinymist_command, string cmd_name, string cmd_desc
local function create_tinymist_command(command_name)
  local export_type = command_name:match("tinymist%.export(%w+)")
  local info_type = command_name:match("tinymist%.(%w+)")
  local log = vim.log.levels

  if info_type and info_type:match("^get") then info_type = info_type:gsub("^get", "Get") end

  local cmd_display = export_type or info_type

  local function run_tinymist_command()
    local bufnr = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_clients({ name = "tinymist", bufnr = bufnr })[1]

    if not client then
      return vim.notify("No Tinymist client attached to the current buffer", vim.log.levels.ERROR)
    end

    local arguments = { vim.api.nvim_buf_get_name(bufnr) }
    local title_str = export_type and ("Export " .. cmd_display) or cmd_display

    local function handler(err, res)
      if err then return vim.notify(err.code .. ": " .. err.message, log.ERROR) end

      vim.notify(
        export_type and "Saved to " .. res or vim.inspect(res),
        log.INFO,
        { title = "tinymist" }
      )
    end

    return client:exec_cmd({
      title = title_str,
      command = command_name,
      arguments = arguments,
    }, { bufnr = bufnr }, handler)
  end

  local cmd_name = (export_type and "LspTinymistExport" or "LspTinymist") .. cmd_display
  local cmd_desc = (export_type and "Export to " or "Get ") .. cmd_display
  return run_tinymist_command, cmd_name, cmd_desc
end

---@type vim.lsp.Config
return {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { ".git", "template.typ", "main.typ" },
  single_file_support = true,
  settings = {
    formatterMode = "typstyle",
    exportPdf = "never",
  },
  on_attach = function(_)
    for _, command in ipairs({
      "tinymist.exportSvg",
      "tinymist.exportPng",
      "tinymist.exportPdf",
      "tinymist.exportHtml", -- Requires typst 0.13.0+
      "tinymist.exportMarkdown",
      "tinymist.exportText",
      "tinymist.exportQuery",
      "tinymist.exportAnsiHighlight",
      "tinymist.getServerInfo",
      "tinymist.getDocumentTrace",
      "tinymist.getWorkspaceLabels",
      "tinymist.getDocumentMetrics",
    }) do
      local cmd_func, cmd_name, cmd_desc = create_tinymist_command(command)
      vim.api.nvim_create_user_command(cmd_name, cmd_func, { nargs = 0, desc = cmd_desc })
    end
  end,
}
