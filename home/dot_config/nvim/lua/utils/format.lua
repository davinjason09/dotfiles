---@class Utils.format
local M = setmetatable({}, {
  __call = function(m, ...) return m.format(...) end,
})

---@class Formatter
---@field name string
---@field format fun(buf:number)

---@type Formatter
M.formatter = nil

---Set formatexpr to conform or LSP
function M.formatexpr()
  if Utils.has("conform.nvim") then return require("conform").formatexpr() end

  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

---Check if formatting is enabled for the current buffer
---@param buf? number
function M.enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local global_format = vim.g.autoformat
  local buffer_format = vim.b[buf].autoformat

  -- If the buffer has a local value, use that value
  if buffer_format ~= nil then return buffer_format end

  -- Otherwise, use the global value if set, or true by default
  return global_format == nil or global_format
end

---Enable or disable autoformatting
---@param enable? boolean
---@param buf? boolean
function M.enable(enable, buf)
  if enable == nil then enable = true end

  if buf then
    vim.b.autoformat = enable
  else
    vim.g.autoformat = enable
    vim.b.autoformat = nil
  end
end

---Toggle autoformatting
---@param buf? boolean
function M.toggle(buf) M.enable(not M.enabled(), buf) end

---Info about the current format settings
---@param buf? number
function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local global_format = vim.g.autoformat == nil or vim.g.autoformat
  local buffer_format = vim.b[buf].autoformat
  local enabled = M.enabled(buf)

  local lines = {
    ("- [%s] `global` %s"):format(global_format and "x" or " ", global_format and "enabled" or "disabled"),
    ("- [%s] `buffer` %s"):format(
      enabled and "x" or " ",
      buffer_format == nil and "inherit" or buffer_format and "enabled" or "disabled"
    ),
  }

  local level = enabled and vim.log.levels.INFO or vim.log.levels.WARN

  vim.notify(table.concat(lines, "\n"), level, { title = "Format" })
end

---Format the current buffer
---@param opts? { force?: boolean, buf?: number }
function M.format(opts)
  opts = opts or {}

  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not ((opts and opts.force) or M.enabled(buf)) then return end

  if M.formatter == nil then return vim.notify("**No formatters set**", vim.log.levels.ERROR) end

  xpcall(function() M.formatter.format(buf) end, function(err)
    vim.schedule(function() vim.notify("Code Format Error: " .. err, vim.log.levels.ERROR) end)
  end)
end

---Check if there is a formatter config in the current or parent directory
---@param dir string
---@param formatter string
function M.has_config(dir, formatter)
  return vim.fs.root(dir, function(name, _)
    local possible_names = Defaults.formatter_rules[formatter]

    if type(possible_names) == "table" then
      return vim.tbl_contains(possible_names, name)
    else
      return name == possible_names
    end
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("CodeFormat", {}),
    callback = function(args)
      if vim.g.minifiles_active then return end

      M.format({ buf = args.buf })
    end,
    desc = "Code Format",
  })

  vim.api.nvim_create_user_command(
    "CodeFormat",
    function() M.format({ force = true }) end,
    { desc = "Format Selection or Buffer" }
  )

  vim.api.nvim_create_user_command("CodeFormatInfo", function() M.info() end, { desc = "Formatter Info (Buffer)" })
end

function M.snacks_toggle(buf)
  return Snacks.toggle({
    name = "Auto Format (" .. (buf and "Buffer" or "Global") .. ")",
    get = function()
      if not buf then return vim.g.autoformat == nil or vim.g.autoformat end
      return Utils.format.enabled()
    end,
    set = function(state) Utils.format.enable(state, buf) end,
  })
end

return M
