vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = true

-- Custom export picker
local export_types = { "pdf", "html", "png", "svg" }

local function export_file()
  vim.ui.select(export_types, { title = "Export file to: " }, function(selected)
    if selected then
      local export_type = selected:sub(1, 1):upper() .. selected:sub(2)
      vim.cmd("TinymistExport" .. export_type)
    end
  end)
end

local map = vim.keymap.set
-- stylua: ignore
map("n", "<leader>ce", "<CMD>LspTinymistExportPdf<CR>", { desc = "[C]ode: [E]xport PDF", buffer = true })
map("n", "<leader>cE", export_file, { desc = "[C]ode: [E]xport Picker", buffer = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.typ",
  group = vim.api.nvim_create_augroup("TypstExportOnSave", { clear = true }),
  callback = function()
    if vim.g.typst_main_file then
      local client = vim.lsp.get_clients({ bufnr = 0, name = "tinymist" })[1]
      if not client then
        vim.notify("Tinymist is not attached", vim.log.levels.WARN)
        return
      end

      -- Check if we're stil in the same root directory
      local root_dir = assert(client.config.root_dir)
      if not vim.startswith(vim.fn.expand("%:p"), root_dir) then
        return vim.notify("File not in the same root directory", vim.log.levels.WARN)
      end

      return client:exec_cmd({
        title = "Export PDF on save",
        command = "tinymist.exportPdf",
        arguments = { vim.g.typst_main_file },
      }, { bufnr = 0 }, function(err)
        if err then return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR) end

        local shortname = vim.fn.fnamemodify(vim.g.typst_main_file, ":.")
        vim.notify(
          ("Exported %s successfully"):format(shortname),
          vim.log.levels.INFO,
          { title = "tinymist" }
        )
      end)
    end
  end,
})
