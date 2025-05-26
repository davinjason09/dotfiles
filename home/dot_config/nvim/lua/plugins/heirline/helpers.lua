local M = {}

M.special_icons = {
  yazi = { "󰇥", "MiniIconsYellow" },
}

-- ╾╼ General Utilities ╾─────────────────────────────────────────────╼

---An `init` function to build multiple update events which is not supported yet by Heirline's update field
---@param opts (string | table)[] An array like table of autocmd events as either just a string or a table with custom patterns and callbacks.
---@return function #Heirline init function
function M.update_events(opts)
  if not vim.islist(opts) then opts = { opts } end

  return function(self)
    if not rawget(self, "once") then
      local function clear_cache() self._win_cache = nil end
      for _, event in ipairs(opts) do
        local event_opts = { callback = clear_cache }
        if type(event) == "table" then
          event_opts.pattern = event.pattern
          if event.callback then
            local callback = event.callback
            event_opts.callback = function(args)
              clear_cache()
              callback(self, args)
            end
          end
          event = event[1]
        end
        vim.api.nvim_create_autocmd(event, event_opts)
      end
      self.once = true
    end
  end
end

---Get the icon and color for a file based on its filename and extension
---@param filename string The filename to get the icon for
---@param extension string The file extension to get the icon for
---@return string, string #The icon and color for the file
function M.get_icon(filename, extension)
  local MiniIcons = require("mini.icons")
  local icon, color, is_default = MiniIcons.get("file", filename)

  local name = vim.fn.fnamemodify(filename, ":t")
  local runtime_path = vim.api.nvim_list_runtime_paths()
  if name == "init.lua" then
    local is_in_runtime_path = false
    for _, path in ipairs(runtime_path) do
      path = path:gsub("-", "%%-")
      if filename:find(path) then
        is_in_runtime_path = true
        break
      end
    end

    -- If the file is not in the runtime path, check for special icons
    -- Currently this is a workaround due to limitation of mini.icons
    if not is_in_runtime_path then
      is_default = true
      for key, value in pairs(M.special_icons) do
        if filename:find(key) then
          icon, color, is_default = value[1], value[2], false
          break
        end
      end
    end
  end

  if is_default then
    icon, color = MiniIcons.get("filetype", extension)
  end

  return icon, color
end

---Redraw the statusline
function M.redraw() vim.cmd.redrawstatus() end

---Check if item is a table of tables
---@param item table
---@return boolean #True if item is a table of tables, false otherwise
function M.is_table_of_tables(item)
  if type(item) ~= "table" then return false end

  for _, v in ipairs(item) do
    if type(v) ~= "table" then return false end
  end

  return true
end

---Check if the current buffer is a location list
function M.is_loclist() return vim.fn.getloclist(0, { filewinid = 0 }).filewinid ~= 0 end

---Timer for spinner
local timer
local timer_running = false

function M.start_spinner()
  if timer_running then return end

  timer = assert(vim.uv.new_timer())
  timer_running = true
  timer:start(
    0,
    50,
    vim.schedule_wrap(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "UpdateSpinner" })
      M.redraw()
    end)
  )
end

function M.stop_spinner()
  if not timer_running then return end

  timer:close()
  timer_running = false
  vim.schedule_wrap(function()
    vim.api.nvim_exec_autocmds("User", { pattern = "UpdateSpinner" })
    M.redraw()
  end)
end

-- ╾╼ Copilot Utilities ╾─────────────────────────────────────────────╼

M.copilot_status = Utils.lazy_require("copilot.status")
M.copilot_client = Utils.lazy_require("copilot.client")
M.copilot_config = Utils.lazy_require("copilot.config")
M.copilot_attached = false

local function _is_current_buffer_attached()
  return M.copilot_client.buf_is_attached(vim.api.nvim_get_current_buf())
end

local function _is_enabled()
  return not M.copilot_client.is_disabled() and _is_current_buffer_attached()
end

local function _is_sleep()
  if vim.b.copilot_suggestion_auto_trigger ~= nil then
    return vim.b.copilot_suggestion_auto_trigger
  end

  return M.copilot_config.suggestion.auto_trigger
end

function M.get_copilot_state()
  local status = M.copilot_status.data.status

  if not _is_enabled() then
    return "disabled"
  elseif status == "InProgress" then
    return "inprogress"
  elseif status == "Warning" then
    return "warning"
  elseif _is_sleep() then
    return "sleep"
  elseif _is_enabled() then
    return "normal"
  else
    return "unknown"
  end
end

function M.is_enabled() return _is_enabled() end

local current_state = nil
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UpdateCopilotStatus", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "copilot" then
      M.copilot_attached = true
      M.copilot_status.register_status_notification_handler(function()
        local new_state = M.get_copilot_state()
        -- Start or stop the spinner based on the state
        if new_state == "inprogress" then
          M.start_spinner()
        elseif current_state == "inprogress" and new_state ~= "inprogress" then
          M.stop_spinner()
        end

        if new_state ~= current_state then
          current_state = new_state
          vim.api.nvim_exec_autocmds("User", { pattern = "UpdateCopilotStatus" })
          M.redraw()
        end
      end)
    end
  end,
})

-- ╾╼ Special Filetypes ╾─────────────────────────────────────────────╼

local function qf_title()
  if M.is_loclist() then return vim.fn.getloclist(0, { title = 0 }).title end
  return vim.fn.getqflist({ title = 0 }).title
end
local function lazy_stats()
  local lazy = require("lazy")
  return "Loaded: " .. lazy.stats().loaded .. "/" .. lazy.stats().count
end

local function mason_stats()
  local registry = require("mason-registry")
  local installed = #registry.get_installed_packages()
  local total = #registry.get_all_package_specs()
  return ("Installed: %s/%s"):format(installed, total)
end

local function picker_stats()
  local filetype = vim.bo.filetype
  local picker = Snacks.picker.get()[1]

  if not picker then return end

  if filetype == "snacks_picker_list" then
    return " " .. vim.fn.fnamemodify(picker:dir(), ":~")
  elseif filetype == "snacks_picker_input" then
    local input = picker.input and picker.input:get() or ""
    local count = #picker:items()
    return input ~= "" and (" " .. input .. ": " .. count .. " results") or (count .. " results")
  else
    local path = picker:current().file
    local filename = vim.fn.fnamemodify(path, ":t")
    local extension = vim.fn.fnamemodify(path, ":e")
    local icon = M.get_icon(filename, extension)
    return "Preview: " .. icon .. " " .. vim.fn.fnamemodify(path, ":~")
  end
end

local function minifiles_cwd()
  local MiniFiles = require("mini.files")

  if vim.bo.filetype:match("help") then return " Help" end

  local cwd = (MiniFiles.get_fs_entry() or {}).path
  return " " .. vim.fn.fnamemodify(cwd, ":~:h")
end

M.SpecialInfo = {
  lazy = lazy_stats,
  mason = mason_stats,
  qf = qf_title,
  picker = picker_stats,
  minifiles = minifiles_cwd,
}

return M
