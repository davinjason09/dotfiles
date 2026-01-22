vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = true
vim.opt_local.iskeyword = "@,48-57,192-255"

vim.b.auto_export = false

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

---@param word string
local function surround(word)
  local start = vim.fn.mode() == "v" and "sa" or "saiw"
  local rest = word
  if vim.startswith(word, "#") and #word > 1 then rest = "]F[i" .. word .. "<ESC>w" end

  vim.fn.feedkeys(Snacks.util.keycode(start .. rest))
end

Snacks.toggle({
  name = "Auto Export",
  get = function() return vim.b.auto_export end,
  set = function(enabled) vim.b.auto_export = enabled end,
}):map("<leader>cx")

local map = vim.keymap.set
-- stylua: ignore start
map("n", "<leader>ce", "<CMD>TinymistExportPdf<CR>", { desc = "[C]ode: [E]xport PDF", buffer = true })
map("n", "<leader>cE", export_file, { desc = "[C]ode: [E]xport Picker", buffer = true })
map({ "n", "x" }, "<A-b>", function() surround("*") end,          { desc = "Surround with *bold*", buffer = true })
map({ "n", "x" }, "<A-i>", function() surround("_") end,          { desc = "Surround with _italic_", buffer = true })
map({ "n", "x" }, "<A-u>", function() surround("#underline") end, { desc = "Surround with underline", buffer = true })
map({ "n", "x" }, "<A-s>", function() surround("#strike") end,    { desc = "Surround with strikethrough", buffer = true })
-- stylua: ignore end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("TypstPinMain", { clear = true }),
  callback = function(ev)
    local allowed_main_name = { "main.typ" }

    local buf_name = vim.fn.fnamemodify(ev.file, ":t")
    local buf_path = vim.fn.fnamemodify(ev.file, ":p:h")
    local cwd = vim.fn.getcwd()
    local client = vim.lsp.get_clients({ name = "tinymist" })[1]

    if not client then return end
    if not vim.tbl_contains(allowed_main_name, buf_name) then return end

    if vim.g.typst_main_file ~= nil then
      local main_buf_path = vim.fn.fnamemodify(vim.g.typst_main_file, ":p:h")
      if main_buf_path == cwd or buf_path ~= cwd then return end
    end

    vim.g.typst_main_file = ev.file
    client:exec_cmd({
      title = "Pin main file",
      command = "tinymist.pinMain",
      arguments = { ev.file },
    })
    vim.notify(
      ("Pinned %s as typst main file"):format(vim.fn.fnamemodify(ev.file, ":.")),
      vim.log.levels.INFO,
      { title = "tinymist" }
    )
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.typ",
  group = vim.api.nvim_create_augroup("TypstExportOnSave", { clear = true }),
  callback = function()
    if vim.g.typst_main_file then
      local client = vim.lsp.get_clients({ bufnr = 0, name = "tinymist" })[1]
      if not client then return vim.notify("Tinymist is not attached", vim.log.levels.WARN) end

      return client:exec_cmd({
        title = "Export PDF on save",
        command = "tinymist.exportPdf",
        arguments = { vim.g.typst_main_file },
      }, { bufnr = 0 }, function(err)
        if err then return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR) end

        local shortname = vim.fn.fnamemodify(vim.g.typst_main_file, ":.")
        vim.notify(("Exported %s successfully"):format(shortname), vim.log.levels.INFO, { title = "tinymist" })
      end)
    elseif vim.b.auto_export then
      vim.cmd("TinymistExportPdf")
    end
  end,
})
