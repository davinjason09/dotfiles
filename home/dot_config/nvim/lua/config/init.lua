local M = {}

local function GetFtIcon(filename)
  local MiniIcons = require("mini.icons")
  local buftype = vim.bo.buftype

  if buftype == "prompt" or buftype == "nofile" then return " " end

  local icon, _, is_default = MiniIcons.get("file", filename)
  return is_default and " " or icon .. " "
end

local title_ignore_ft = {
  "snacks_dashboard",
  "mini.files",
}

M.title = function()
  local ft = vim.bo.filetype
  local filename = vim.fn.expand("%:t")

  local icon = filename ~= "" and GetFtIcon(filename) or " "
  filename = filename == "" and "[No File]" or filename
  filename = vim.tbl_contains(title_ignore_ft, ft) and "" or filename .. " "

  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  return string.format("%s%s-  %s", icon, filename, cwd)
end

---@param name "autocmds" | "commands" | "keymaps" | "lsp" | "options"
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

  Utils.clear_lsp_log()
  M.load("options")
end

M.setup = function()
  -- Boostrap lazy.nvim
  require("config.lazy")
  M.load("commands")
  M.load("lsp")

  -- Lazy load autocmds when not opening a file
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then M.load("autocmds") end

  -- Load keymaps and autocommands on VeryLazy
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("CustomSetup", { clear = true }),
    pattern = "VeryLazy",
    callback = function()
      -- HACK:
      -- Declaring `vim.o.titlestring` in options.lua will emit E5108 for MiniIcons if `vim.fn.argc(-1) == 1`
      -- To combat this, we set the title here after lazy has sourced all plugin modules
      vim.o.title = true
      vim.o.titlestring = "%{v:lua.require('config').title()}"

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
