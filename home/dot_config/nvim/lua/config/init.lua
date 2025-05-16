local M = {}

---@param name "autocmds" | "commands" | "filetypes" | "keymaps" | "lsp" | "options"
M.load = function(name)
  ---@param mod string
  local function _load(mod)
    local U = require("lazy.core.util")
    if require("lazy.core.cache").find(mod)[1] then
      U.try(function() require(mod) end, { msg = "Failed to load " .. mod })
    end
  end

  _load("config." .. name)

  if vim.bo.filetype == "lazy" then vim.cmd([[do VimResized]]) end
end

M.did_init = false
M.init = function()
  if M.did_init then return end

  M.did_init = true
  M.load("options")
end

M.setup = function()
  -- Boostrap lazy.nvim
  require("config.lazy")
  M.load("commands")
  M.load("filetypes")
  M.load("lsp")

  -- Lazy load autocmds when not opening a file
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then M.load("autocmds") end

  -- Load keymaps and autocommands on VeryLazy
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("CustomSetup", { clear = true }),
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then M.load("autocmds") end

      M.load("keymaps")
    end,
  })

  local U = require("lazy.core.util")
  U.track("colorscheme")
  U.try(
    function() vim.cmd.colorscheme("catppuccin") end,
    { msg = "Failed to load colorscheme", on_error = function(msg) U.error(msg) end }
  )
  U.track()
end

return M
