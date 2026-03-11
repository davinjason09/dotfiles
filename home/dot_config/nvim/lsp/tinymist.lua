---@param command_name string
---@param client vim.lsp.Client
---@param bufnr integer
---@return fun():nil run_tinymist_command, string cmd_name, string cmd_desc
local function create_tinymist_command(command_name, client, bufnr)
  local export_type = command_name:match("tinymist%.export(%w+)")
  local info_type = command_name:match("tinymist%.(%w+)")
  local cmd_display = export_type or info_type:gsub("^get", "Get"):gsub("^pin", "Pin")

  local function run_tinymist_command()
    local arguments = { vim.api.nvim_buf_get_name(bufnr) }
    local title_str = export_type and ("Export " .. cmd_display) or cmd_display

    ---@param err lsp.ResponseError?
    ---@param res any
    local function handler(err, res)
      if err then return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR) end

      local message = export_type and "Saved to " .. vim.fn.fnamemodify(res.path, ":.") or vim.inspect(res)
      vim.notify(message, vim.log.levels.INFO, { title = "tinymist" })
    end

    return client:exec_cmd({
      title = title_str,
      command = command_name,
      arguments = arguments,
    }, { bufnr = bufnr }, handler)
  end

  local cmd_name = (export_type and "TinymistExport" or "Tinymist") .. cmd_display ---@type string
  local cmd_desc = (export_type and "Export to " or "Get ") .. cmd_display ---@type string
  return run_tinymist_command, cmd_name, cmd_desc
end

---@type vim.lsp.Config
return {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { { "lib.typ", "main.typ" }, ".git" },
  single_file_support = true,
  settings = {
    exportPdf = "never",
    formatterMode = "typstyle",
  },
  on_attach = function(client, bufnr)
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
      "tinymist.pinMain",
    }) do
      local cmd_func, cmd_name, cmd_desc = create_tinymist_command(command, client, bufnr)
      -- stylua: ignore
      vim.api.nvim_buf_create_user_command(bufnr, cmd_name, cmd_func, { nargs = 0, desc = cmd_desc }) 
    end

    local map = vim.keymap.set
    map("n", "<leader>cP", function()
      if not client then return vim.notify("Tinymist is not attached", vim.log.levels.WARN) end

      local file = vim.api.nvim_buf_get_name(bufnr)

      client:exec_cmd({
        title = "pin",
        command = "tinymist.pinMain",
        arguments = { file },
      }, { bufnr = bufnr }, function(err)
        if err then return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR) end

        local shortname = vim.fn.fnamemodify(file, ":.")
        vim.notify("Successfully pinned " .. shortname, vim.log.levels.INFO, { title = "tinymist" })
        vim.g.typst_main_file = file
      end)
    end, { desc = "[C]ode: [P]in", buffer = bufnr })

    map("n", "<leader>cu", function()
      if not client then return vim.notify("Tinymist is not attached", vim.log.levels.WARN) end

      if not vim.g.typst_main_file then
        return vim.notify("No main file pinned", vim.log.levels.WARN, { title = "tinymist" })
      end

      client:exec_cmd({
        title = "unpin",
        command = "tinymist.pinMain",
        arguments = { vim.v.null },
      }, { bufnr = bufnr }, function(err)
        if err then return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR) end

        local shortname = vim.fn.fnamemodify(vim.g.typst_main_file, ":.")
        vim.notify("Unpinned " .. shortname, vim.log.levels.INFO, { title = "tinymist" })
        vim.g.typst_main_file = nil
      end)
    end, { desc = "[C]ode: [U]npin", buffer = bufnr })
  end,
}
