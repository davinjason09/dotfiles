vim.g.project_settings = vim.g.project_settings or {}

local function toml_to_json(path)
  local res = vim.system({ "toml2json", path }, { text = true }):wait()
  return (res.code == 0 or res.stderr == "") and vim.json.decode(res.stdout) or {}
end

local function parse_toml(path)
  local root = vim.fs.dirname(path)
  local file = vim.fs.basename(path)
  local key = ("%s:%s"):format(root, file)

  local cache = vim.g.project_settings
  if cache[key] then return cache[key] end

  local result = toml_to_json(path)
  cache[key] = file == "pyproject.toml" and (vim.tbl_get(result, "tool", "ruff") or {}) or result
  vim.g.project_settings = cache

  return cache[key]
end

local function parse_settings()
  local root = vim.fs.root(0, { "pyproject.toml", "ruff.roml" })
  if not root then return end

  require("custom.scripts.watch").start(root, function(_, file)
    if not file then return end

    local ext = vim.fn.fnamemodify(file, ":e")
    if ext ~= "toml" then return end

    vim.schedule(function()
      local path = vim.fs.joinpath(root, file)
      local key = ("%s:%s"):format(root, file)
      local cache = vim.g.project_settings

      local result = toml_to_json(path)
      cache[key] = file == "pyproject.toml" and (vim.tbl_get(result, "tool", "ruff") or {}) or result
      vim.g.project_settings = cache
    end)
  end)

  -- Parse pyproject.toml first, then ruff.toml if there's no ruff settings in it
  local path = vim.fs.joinpath(root, "pyproject.toml")
  local settings = vim.uv.fs_stat(path) and parse_toml(path) or {}

  if not settings then
    path = vim.fs.joinpath(root, "ruff.toml")
    settings = vim.uv.fs_stat(path) and parse_toml(path) or {}
  end

  return settings
end

local settings = parse_settings()

local indent_width = vim.tbl_get(settings, "indent-width")
local indent = tonumber(indent_width) or 2

vim.opt_local.tabstop = indent
vim.opt_local.shiftwidth = indent
vim.opt_local.softtabstop = indent
vim.opt_local.expandtab = vim.tbl_get(settings, "format") or "space" ~= "tab"
