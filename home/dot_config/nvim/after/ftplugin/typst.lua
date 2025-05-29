vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = true

-- Custom export picker
local export_types = { "pdf", "html", "png", "svg" }

local function export_file()
  vim.ui.select(export_types, { title = "Export file to: " }, function(selected)
    if selected then
      local export_type = selected:sub(1, 1):upper() .. selected:sub(2)
      vim.cmd("LspTinymistExport" .. export_type)
    end
  end)
end

local ignored_files = { "template.typ" }

local map = vim.keymap.set
-- stylua: ignore
map("n", "<leader>ce", "<CMD>LspTinymistExportPdf<CR>", { desc = "[C]ode: [E]xport PDF", buffer = true })
map("n", "<leader>cE", export_file, { desc = "[C]ode: [E]xport Picker", buffer = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.typ",
  group = vim.api.nvim_create_augroup("TypstExportOnSave", { clear = true }),
  callback = function()
    if not vim.tbl_contains(ignored_files, vim.fn.expand("%:t")) then
      vim.cmd.LspTinymistExportPdf()
    end
  end,
})
