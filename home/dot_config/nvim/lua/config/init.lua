local M = {}

local function get_ft_icon(filename)
  -- PERF:
  -- If the filetype is "prompt" or "nofile", return a default icon
  -- This was done because MiniIcons.get() hit the stack limit when trying to get the icon
  -- for these filetypes (I assume it happened because the buffer updates a lot when the
  -- picker is resolving the items), especially when the Snacks picker is open.
  local buftype = vim.bo.buftype
  if buftype == "prompt" or buftype == "nofile" then return " " end

  local icon = Snacks.util.icon(filename, "file", { fallback = { file = " " } })
  return icon
end

local title_ignore_ft = {
  "snacks_dashboard",
  "mini.files",
}

M.title = function()
  local ft = vim.bo.filetype
  local filename = vim.fn.expand("%:t")

  local icon = filename ~= "" and get_ft_icon(filename) or " "
  if filename == "" then
    filename, icon = Defaults.title_name(ft, vim.bo.buftype)
  end

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
M._options = {} ---@type vim.wo|vim.bo

M.init = function()
  if M.did_init then return end
  M.did_init = true

  Utils.lazy_notify()
  Utils.clear_lsp_log()
  M.load("options")

  M._options.indentexpr = vim.o.indentexpr
  M._options.foldmethod = vim.o.foldmethod
  M._options.foldexpr = vim.o.foldexpr

  local mason_path = vim.fn.stdpath("data") .. "/mason/bin"
  if vim.fn.isdirectory(mason_path) == 1 then vim.env.PATH = mason_path .. ":" .. vim.env.PATH end
end

M.setup = function()
  -- Boostrap lazy.nvim
  require("config.lazy")
  M.load("commands")
  M.load("lsp")

  -- Lazy load autocmds when not opening a file
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then M.load("autocmds") end

  -- HACK:
  -- Declaring `vim.o.titlestring` in options.lua will emit E5108 for MiniIcons if `vim.fn.argc(-1) == 1`
  -- To combat this, we set the title here after we setup lazy.nvim
  vim.o.title = true
  vim.o.titlestring = "%{v:lua.require('config').title()}"

  -- Load keymaps and autocommands on VeryLazy
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("CustomSetup", { clear = true }),
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then M.load("autocmds") end

      M.load("keymaps")

      Utils.format.setup()
    end,
  })
end

return M
