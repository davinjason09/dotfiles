---@class Utils.ui
local M = {}

---Check if the current screen is small based on the default threshold
function M.is_small_screen()
  local height = vim.o.lines
  return height <= Defaults.small_screen_threshold
end

---@type table<string, boolean>?
M._installed_parser = nil

---@type table<string, boolean>
M._queries = {}

---@param update boolean?
function M.get_installed(update)
  if update then
    M._installed_parser, M._queries = {}, {}
    for _, lang in ipairs(require("nvim-treesitter").get_installed("parsers")) do
      M._installed_parser[lang] = true
    end
  end

  return M._installed_parser or {}
end

---@param lang string
---@param query string
function M.have_query(lang, query)
  local key = lang .. ":" .. query
  if M._queries[key] == nil then M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil end

  return M._queries[key]
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]

  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then return false end
  if query and not M.have_query(lang, query) then return false end

  return true
end

-- Optimized treesitter foldexpr
function M.foldexpr() return M.have(nil, "folds") and vim.treesitter.foldexpr() or "0" end

function M.indentexpr()
  return M.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1
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

return M
