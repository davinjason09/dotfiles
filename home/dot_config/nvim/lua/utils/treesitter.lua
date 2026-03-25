---@class Utils.treesitter
local M = {}

M._installed_parser = nil ---@type table<string, boolean>?
M._queries = {} ---@type table<string, boolean>

---@param update boolean?
M.get_installed = function(update)
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
M.have_query = function(lang, query)
  local key = lang .. ":" .. query
  if M._queries[key] == nil then M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil end

  return M._queries[key]
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
M.have = function(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == "number" and vim.bo[what].filetype or what ---@diagnostic disable-line: undefined-field

  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then return false end
  if query and not M.have_query(lang, query) then return false end

  return true
end

-- Optimized treesitter foldexpr
M.foldexpr = function() return M.have(nil, "folds") and vim.treesitter.foldexpr() or "0" end

M.indentexpr = function() return M.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1 end

-- Taken from: https://github.com/OXY2DEV/nvim/blob/main/lua/plugins/tree-sitter.lua#L159
-- With some modifications

---@param name string
---@param owner string
---@return string?
---@return ("path"|"url")?
local function path_or_url(name, owner)
  if not (name and owner) then
    return vim.notify("register_parser: Either `name` or `owner` is empty!", vim.log.levels.WARN)
  end

  local path = vim.fs.joinpath(vim.fn.stdpath("config"), "parsers", ("tree-sitter-%s"):format(name))
  local url = ("https://github.com/%s/tree-sitter-%s"):format(owner, name)

  local path_stat = vim.uv.fs_stat(path)

  if path_stat and path_stat.type == "directory" then
    return path, "path"
  else
    return url, "url"
  end
end

M._update = {}

---@class ParserOpts
---@field name? string
---@field owner? string
---@field path? string
---@field url? string
---@field maintainers? string[]
---@field requires? string[]
---@field revision? string
---@field branch? string
---@field location? string
---@field queries? string
---@field register? boolean
---@field filetype? string
---@field generate? boolean
---@field generate_from_json? boolean

---@param lang string
---@param opts ParserOpts
M.register_parser = function(lang, opts)
  local path, path_type = path_or_url(opts.name or lang, opts.owner)
  M._update[lang] = {
    install_info = {
      url = path_type == "url" and path or nil,
      path = path_type == "path" and path or nil,
      branch = opts.branch,
      requires = opts.requires,
      revision = opts.revision,
      location = opts.location,
      queries = opts.queries or "queries/",
      generate = opts.generate or false,
      generate_from_json = opts.generate_from_json or false,
    },
  }

  if opts.register then vim.treesitter.language.register(opts.filetype, lang) end
end

return M
