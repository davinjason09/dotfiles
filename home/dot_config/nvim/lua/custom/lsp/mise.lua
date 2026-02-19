local M = {}

local opts = {
  initial_path = vim.env.PATH,
}

local function get_data()
  local full_command = { "mise", "env", "--json" }
  local env_sh = vim.system(full_command, { text = true }):wait()

  -- Warn the user instead of returning nil
  if env_sh.stderr ~= nil then vim.notify(vim.trim(env_sh.stderr), vim.log.levels.WARN) end

  local ok, data = pcall(vim.json.decode, env_sh.stdout)
  if not ok or type(data) == "string" then
    return vim.notify('Invalid json returned by "' .. full_command .. '"', vim.log.levels.ERROR)
  end

  return data
end

local function load_env(data)
  for var_name, var_value in pairs(data) do
    vim.env[var_name] = var_value
  end
end

M._did_setup = false
M.setup = function()
  if M._did_setup then return end
  M._did_setup = true

  local data = get_data()
  if data == nil then return end

  vim.env.PATH = opts.initial_path
  load_env(data)
end

return M
