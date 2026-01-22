local M = {}

local opts = {
  cmd = "mise",
  args = "env --json",
  initial_path = vim.env.PATH,
}

local function get_data()
  local full_command = opts.cmd .. " " .. opts.args
  local env_sh = vim.fn.system(full_command)

  if env_sh:find("^mise") ~= nil then return vim.notify(env_sh:match("^[^\n]*"), vim.log.levels.ERROR) end

  local ok, data = pcall(vim.json.decode, env_sh)
  if not ok or data == nil then
    return vim.notify('Invalid json returned by "' .. full_command .. '"', vim.log.levels.ERROR)
  end

  return data
end

local function load_env(data)
  for var_name, var_value in pairs(data) do
    vim.env[var_name] = var_value
  end
end

M.setup = function()
  local data = get_data()
  if data == nil then return end

  vim.env.PATH = opts.initial_path
  load_env(data)
end

return M
