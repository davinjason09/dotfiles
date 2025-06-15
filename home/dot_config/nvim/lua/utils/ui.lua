---@class Utils.ui
local M = {}

---Check if the current screen is small based on the default threshold
function M.is_small_screen()
  local height = vim.o.lines
  return height <= Defaults.small_screen_threshold
end

-- Optimized treesitter foldexpr
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filtype, don't bother checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then return "0" end

    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end

  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

local lang_parse = {
  lua = function() end,
  typst = function() end,
}

---@param opts blink.cmp.CompletionDocumentationDrawOpts
function M.parse_doc(opts) end

return M
