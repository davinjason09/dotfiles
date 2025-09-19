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
  return M.have(vim.b[buf].filetype) and vim.treesitter.foldexpr() or "0"
end

    end
  end

function M.indentexpr()
  local buf = vim.api.nvim_get_current_buf()
  return M.have(vim.b[buf].filetype) and require("nvim-treesitter").indentexpr() or -1
end

---Add powerline symbols to the title of popups
---@alias title_opts { msg: string, views?: string, kind?: string }
---@param opts title_opts
function M.noice_title(opts)
  opts.views = opts.views or "cmdline_popup"

  local powerline_hl = ""
  if opts.views == "confirm" then
    powerline_hl = "NoiceConfirmBorder"
  elseif opts.kind then
    powerline_hl = "NoiceCmdlinePopupBorder" .. opts.kind:sub(1, 1):upper() .. opts.kind:sub(2)
  end

  return {
    { "", powerline_hl },
    { opts.msg },
    { "", powerline_hl },
  }
end

M.installed_parser = {}

function M.have(ft)
  local lang = vim.treesitter.language.get_lang(ft)
  return vim.tbl_contains(M.installed_parser, lang)
end
return M
