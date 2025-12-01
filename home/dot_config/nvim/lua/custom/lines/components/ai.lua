local M = {}

---@class lsp.Status
---@field busy boolean
---@field kind "Normal" | "Error" | "Warning" | "Inactive"
---@field message? string

---@type table<integer, lsp.Status>
local status = {}

local levels = {
  Normal = vim.log.levels.INFO,
  Warning = vim.log.levels.WARN,
  Error = vim.log.levels.ERROR,
  Inactive = vim.log.levels.WARN,
}

local function is_copilot(client)
  local name = type(client) == "table" and client.name or client
  return name and name:lower():find("copilot") ~= nil
end

---@param err? lsp.ResponseError
---@param res lsp.Status
---@param ctx lsp.HandlerContext
M.on_status = function(err, res, ctx)
  if err then return end

  status[ctx.client_id] = vim.deepcopy(res)
  local level = levels[res.kind or "Normal"] or vim.log.levels.INFO
  vim.api.nvim_exec_autocmds("User", { pattern = "UpdateCopilotStatus", modeline = false })

  local U = require("custom.lines.utils")
  local exec_spinner = res.busy and U.start_spinner or U.stop_spinner
  exec_spinner()

  if res.message and level >= vim.log.levels.WARN then
    local msg = res.message
    if msg:find("not signed") ~= nil and package.loaded.copilot then
      msg = msg .. "\nPlease use `:Copilot auth` to sign in."
    end

    vim.notify(msg, level, { title = "Copilot" })
  end
end

---@param client vim.lsp.Client
M.attach = function(client) client.handlers.didChangeStatus = M.on_status end

---@param buf? integer
---@return lsp.Status?
M.get_status = function(buf)
  ---@type vim.lsp.Client
  local client = vim.tbl_filter(is_copilot, vim.lsp.get_clients({ bufnr = buf or 0 }))[1]

  return client and status[client.id] or { busy = false, kind = "Normal" } or nil
end

M.setup = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CopilotStatus", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and not is_copilot(client) then return end

      M.attach(client)
      local all_clients = vim.tbl_filter(is_copilot, vim.lsp.get_clients())
      for _, c in ipairs(all_clients) do
        M.attach(c)
      end
    end,
  })
end

M.Copilot = {
  static = {
    icon = {
      Normal = " ",
      Warning = " ",
      Error = " ",
      Inactive = "",
    },
    color = {
      ["Normal"] = "lavender",
      ["Warning"] = "yellow",
      ["Error"] = "red",
      ["InProgress"] = "green",
      ["Inactive"] = "overlay2",
    },
  },
  condition = function() return Utils.is_loaded("copilot.lua") and M.get_status() ~= nil end,
  update = { "User", pattern = { "UpdateSpinner", "UpdateCopilotStatus" } },
  {
    condition = function() return (M.get_status() or {}).busy or false end,
    update = { "User", pattern = "UpdateSpinner" },
    provider = function() return " " .. Snacks.util.spinner() end,
    hl = { fg = "green" },
  },
  {
    update = { "User", pattern = "UpdateCopilotStatus" },
    provider = function(self) return (" %s "):format(self.icon[(M.get_status() or {}).kind]) end,
    hl = function(self)
      local state = M.get_status() or {}

      if state.busy then return { fg = self.color["InProgress"] } end
      return { fg = self.color[state.kind] }
    end,
  },
}

return M
