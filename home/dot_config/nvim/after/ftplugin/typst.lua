vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = true

local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local npairs = require("nvim-autopairs")
local ts_conds = require("nvim-autopairs.ts-conds")

npairs.add_rules({
  Rule("```", "```", "typst"),
  Rule("$", "$", "typst")
    :with_pair(cond.not_after_regex("[%w]"))
    :with_pair(ts_conds.is_not_ts_node("math"))
    :with_move(ts_conds.is_ts_node("math"))
    :replace_map_cr(function() return "<C-g>u<CR><ESC>O<Tab>" end),
  Rule("_", "_", "typst")
    :with_pair(cond.not_before_regex("[%w]"))
    :with_pair(cond.not_after_regex("[%w]")),
  Rule("*", "*", "typst")
    :with_pair(cond.not_before_regex("[%w]"))
    :with_pair(cond.not_after_regex("[%w]")),
  Rule("~", "~", "typst")
    :with_pair(cond.not_before_regex("[%w]"))
    :with_pair(cond.not_after_regex("[%w]")),
})

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
    if vim.g.typst_main_file then
      local client = vim.lsp.get_clients({ bufnr = 0, name = "tinymist" })[1]
      if not client then
        vim.notify("Tinymist is not attached", vim.log.levels.WARN)
        return
      end

      -- Check if we're stil in the same root directory
      local root_dir = assert(client.config.root_dir)
      if not vim.startswith(vim.fn.expand("%:p"), root_dir) then
        vim.notify("File not in the same root directory", vim.log.levels.WARN)
        return
      end

      client:exec_cmd({
        title = "Export PDF on save",
        command = "tinymist.exportPdf",
        arguments = { vim.g.typst_main_file },
      }, { bufnr = 0 }, function(err)
        if err then return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR) end

        vim.notify("Exported PDF successfully", vim.log.levels.INFO, { title = "tinymist" })
      end)
      return
    end

    -- If no main file is set, export the current file
    if not vim.tbl_contains(ignored_files, vim.fn.expand("%:t")) then
      vim.cmd.LspTinymistExportPdf()
    end
  end,
})
