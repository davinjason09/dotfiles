---@class Utils
---@field edit       Utils.edit
---@field format     Utils.format
---@field mini       Utils.mini
---@field treesitter Utils.treesitter
local M = {}

setmetatable(M, {
  __index = function(t, key)
    t[key] = require("utils." .. key)
    return t[key]
  end,
})

---Get current nvim version
---@return string #The current nvim version
M.nvim_version = function()
  local v = vim.fn.api_info().version ---@type vim.Version
  return ("%d.%d.%d%s"):format(v.major, v.minor, v.patch, v.prerelease and "-dev" or "")
end

---Get the specified plugin
---@param name string The name of the plugin
M.get_plugin = function(name) return require("lazy.core.config").spec.plugins[name] end

---Check if the plugin exists
---@param plugin string The name of the plugin
M.has = function(plugin) return M.get_plugin(plugin) ~= nil end

---Execute code on `VeryLazy` event
---@param func fun() The function to run on `VeryLazy` event
M.on_very_lazy = function(func)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function() func() end,
  })
end

---Get the specified plugin's options
---@param name string The name of the plugin
M.opts = function(name)
  local plugin = M.get_plugin(name)

  if not plugin then return {} end

  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

---Check if the plugin is loaded
---@param name string The name of the plugin
M.is_loaded = function(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---Execute code when a plugin is loaded
---@param name string            The name of the plugin
---@param func fun(name: string) The code to load when the plugin is loaded
M.on_load = function(name, func)
  if M.is_loaded(name) then
    func(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(ev)
        if ev.data == name then
          func(name)
          return true
        end
      end,
    })
  end
end

-- Delay notifications till vim.notify was replaced or after 500ms
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua#L138
M.lazy_notify = function()
  local notifs = {}
  local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end

  local orig = vim.notify
  vim.notify = temp

  local timer, check = assert(vim.uv.new_timer()), assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()

    -- put back the original notify if needed
    if vim.notify == temp then vim.notify = orig end

    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then replay() end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

---Deduplicate a list
---@generic T
---@param list T[]
---@param opts? { func: fun(x: T) }
---@return T[]
M.dedup = function(list, opts)
  opts = opts or {}
  local ret = {}
  local seen = {}

  for _, v in ipairs(list) do
    local key = opts.func and opts.func(v) or v

    if not seen[key] then
      table.insert(ret, v)
      seen[key] = true
    end
  end

  return ret
end

---@alias IconType "file"|"filetype"|"directory"

---Get the icon and color for a file based on its filename and extension
---@param entry { fs_type: IconType, path: string } The file entry containing type and path
---@return string, string, boolean The icon, color, and whether it's a default icon
M.get_icon = function(entry)
  local MiniIcons = _G.MiniIcons or require("mini.icons")
  local name = vim.fs.basename(entry.path)
  local icon, color, is_default = MiniIcons.get(entry.fs_type, name)

  if name == "init.lua" and entry.fs_type == "file" then
    local in_runtime_path = vim
      .iter(vim.api.nvim_list_runtime_paths())
      :any(function(path) return entry.path:find(path) ~= nil end)

    if in_runtime_path then goto continue end

    -- If the file is not in the runtime path, check for special icons
    -- Currently this is a workaround due to limitation of mini.icons
    is_default = true
    for key, value in pairs(Defaults.special_ft_icons) do
      if entry.path:find(key) ~= nil then
        icon, color, is_default = value[1], value[2], false
        break
      end
    end
  end

  ::continue::
  if is_default and entry.fs_type ~= "directory" then
    local ft = vim.filetype.match({ filename = entry.path }) or ""
    icon, color, is_default = MiniIcons.get("filetype", ft)
  end

  return icon .. " ", color, is_default
end

---Get all LSP clients attached to the current buffer
---@return string[] A list of LSP client names
M.get_lsp_clients = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local attached = vim.iter(clients):map(function(c) return c.name ~= "copilot" and c.name or nil end):totable()
  return M.dedup(attached)
end

---Clear LSP log if it exceeds a certain size
M.clear_lsp_log = function()
  local log_path = vim.lsp.log.get_filename()

  if log_path and vim.fn.filereadable(log_path) then
    local file_size = vim.fn.getfsize(log_path)

    if file_size > Defaults.bigfile.size then
      os.remove(log_path)
      vim.notify("LSP log file exceeded size limit and was deleted")
    end
  end
end

---@return string
local function detect_terminal()
  local e = vim.env
  if e.TERM_PROGRAM then
    local v = e.TERM_PROGRAM_VERSION ---@type string?
    return e.TERM_PROGRAM_VERSION and (e.TERM_PROGRAM .. " " .. v) or e.TERM_PROGRAM
  end

  -- stylua: ignore
  local map = {
    KITTY_WINDOW_ID    = "kitty",
    ALACRITTY_SOCKET   = "alacritty",
    ALACRITTY_LOG      = "alacritty",
    WEZTERM_EXECUTABLE = "wezterm",
    KONSOLE_VERSION    = function() return "konsole " .. e.KONSOLE_VERSION end,
    VTE_VERSION        = function() return "vte " .. e.VTE_VERSION end,
  }

  for key, val in pairs(map) do
    local env = e[key] --- @type string?
    if env then return type(val) == "string" and val or val() end
  end

  return "unknown"
end

---@param opts { open: boolean }
---@return string?
M.report = function(opts)
  opts = vim.tbl_extend("force", { open = true }, opts)

  local version_out = vim.api.nvim_exec2("version", { output = true }).output
  local nvim_version = version_out:match("NVIM (v[^\n]+)") or "unknown"
  local commit = (version_out:match("%+g(%x+)") or ""):sub(1, 12) ---@type string

  local os_info = vim.uv.os_uname()
  local os_string = os_info.sysname .. " " .. os_info.release
  local terminal = detect_terminal()
  local term_env = vim.env.TERM or "unknown"

  local msg = [[
    ## Problem

    Describe the problem (concisely).

    ## Steps to reproduce

    ```
    nvim --clean
    ```

    ## Expected behavior

    ## System info

    - Nvim version (nvim -v): `%s` neovim/neovim@%s
    - Vim (not Nvim) behaves the same?: ?
    - Operating system/version: %s
    - Terminal name/version: %s
    - $TERM environment variable: `%s`
    - Installation: ?

  ]]
  local body = vim.text.indent(0, (msg):format(nvim_version, commit, os_string, terminal, term_env))
  local encoded_body = vim.uri_encode(body) --- @type string
  local issue_url = "https://github.com/neovim/neovim/issues/new?type=Bug&body=" .. encoded_body

  if not opts.open then return issue_url end

  vim.ui.open(issue_url)
end

return M
