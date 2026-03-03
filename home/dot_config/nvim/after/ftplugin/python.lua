vim.g.pyproject_dump = {}

local function parse_pyproject_toml()
  local root = vim.fs.root(0, "pyproject.toml")
  if not root then return end

  local pyproject = vim.fs.joinpath(root, "pyproject.toml")
  local cache = vim.g.pyproject_dump
  local json_blob = cache[root] or ""

  vim
    .system({ "toml2json", pyproject }, { text = true }, function(obj)
      if obj.code ~= 0 or obj.stderr ~= "" then return end
      json_blob = obj.stdout
    end)
    :wait()

  if cache[root] == json_blob then return cache[root] end

  cache[root] = json_blob
  vim.g.pyproject_dump = cache

  return vim.json.decode(json_blob)
end

local settings = parse_pyproject_toml() or {}
local formatter_settings = settings.tool and settings.tool.ruff or {}
formatter_settings.format = formatter_settings.format or {}

vim.opt_local.tabstop = tonumber(formatter_settings["indent-width"]) or 2
vim.opt_local.shiftwidth = tonumber(formatter_settings["indent-width"]) or 2
vim.opt_local.softtabstop = tonumber(formatter_settings["indent-width"]) or 2
vim.opt_local.expandtab = (formatter_settings.format["indent-style"] or "space") ~= "tab"
