local M = {}

local C = require("heirline.conditions")
local U = require("plugins.heirline.helpers")

M.Align = { provider = "%=" }

---@param n? number The amount of spaces to add
---@return table
M.Space = function(n) return { provider = string.rep(" ", n or 1) } end

---@alias SeparatorHL {fg: string, bg: string} | fun(self: table): {fg: string, bg: string}

---@param icon string
---@param hl SeparatorHL
---@param update? string | table | (string | table)[] | fun(self: table): bool
---@param init? (string | table)[]
---@return table
M.Separator = function(icon, hl, update, init)
  local comp = {
    provider = icon,
    hl = hl,
  }

  if init then comp.init = U.update_events(init) end
  if update then comp.update = update end

  return comp
end

-- ╭─────────────────────────────────────────────────────────╮
-- │              Default Statusline Components              │
-- ╰─────────────────────────────────────────────────────────╯

-- Vim modes, as the name suggest
M.ViMode = {
  static = {
    mode_map = {
      ["n"] = "NORMAL",
      ["niI"] = "NORMAL",
      ["niR"] = "NORMAL",
      ["niV"] = "NORMAL",
      ["no"] = "O-PENDING",
      ["nov"] = "O-PENDING",
      ["noV"] = "O-PENDING",
      ["no\22"] = "O-PENDING",

      ["v"] = "VISUAL",
      ["vs"] = "VISUAL",
      ["V"] = "V-LINE",
      ["Vs"] = "V-LINE",
      ["\22"] = "V-BLOCK",
      ["\22s"] = "V-BLOCK",

      ["s"] = "SELECT",
      ["S"] = "S-LINE",
      ["\19"] = "S-BLOCK",

      ["i"] = "INSERT",
      ["ic"] = "INSERT",
      ["ix"] = "INSERT",

      ["R"] = "REPLACE",
      ["Rc"] = "REPLACE",
      ["Rx"] = "REPLACE",
      ["Rv"] = "V-REPLACE",
      ["Rvc"] = "V-REPLACE",
      ["Rvx"] = "V-REPLACE",

      ["r"] = "PROMPT",
      ["rm"] = "MORE",
      ["r?"] = "CONFIRM",
      ["x"] = "CONFIRM",

      ["c"] = "COMMAND",
      ["cv"] = "COMMAND",
      ["ce"] = "COMMAND",
      ["cr"] = "COMMAND",
      ["!"] = "SHELL",

      ["t"] = "TERMINAL",
      ["nt"] = "NTERMINAL",
      ["ntT"] = "NTERMINAL",
    },
  },
  init = U.update_events({
    { "User", pattern = "GitSignsUpdate", callback = U.redraw() },
    { "User", pattern = "GitSignsChanged", callback = U.redraw() },
  }),
  update = { "User", pattern = "ForceRedraw", callback = U.redraw() },
  provider = function(self)
    return string.format(" %s %s ", self:mode_icon(), self.mode_map[vim.fn.mode(1)])
  end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color(), bold = true } end,
  M.Separator(
    "",
    function(self) return { fg = self:mode_color(), bg = C.is_git_repo() and "surface0" or "crust" } end,
    nil,
    {
      { "User", pattern = "GitSignsUpdate", callback = U.redraw() },
      { "User", pattern = "ForceRedraw", callback = U.redraw() },
    }
  ),
}

-- Git Branch
M.GitBranch = {
  condition = C.is_git_repo,
  static = { branch_icon = "" },
  init = U.update_events({
    "BufEnter",
    { "User", pattern = "GitSignsUpdate", callback = U.redraw() },
    { "User", pattern = "GitSignsChanged", callback = U.redraw() },
  }),
  update = { "User", pattern = "ForceRedraw", callback = U.redraw() },
  provider = function(self) return string.format(" %s %s ", self.branch_icon, vim.b.gitsigns_head) end,
  hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
  M.Separator("", { fg = "surface0", bg = "crust" }),
}

-- File Name, contains icons, pretty path and flags
M.FileNameBlock = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
  -- File Icons
  {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ":e")
      self.icon, self.color = U.get_icon(filename, extension)
    end,
    provider = function(self) return (" %s "):format(self.icon) end,
    hl = function(self) return { fg = self.color, bg = "crust" } end,
  },
  -- File pretty path
  {
    init = function(self)
      self.path = vim.fn.fnamemodify(self.filename, ":.")
      self.path_split = vim.split(self.path, "/")
    end,
    {
      condition = function() return vim.bo.filetype ~= "help" and vim.bo.buftype ~= "terminal" end,
      provider = function(self)
        if self.path == "" then return "[No Name]" end

        if self.path:find("Scratch") then return "[Scratch]" end

        if #self.path_split > 3 then
          return string.format(
            "%s/…/%s/",
            self.path_split[1],
            self.path_split[#self.path_split - 1]
          )
        else
          local concat_path = table.concat(self.path_split, "/", 1, #self.path_split - 1)
          return concat_path ~= "" and string.format("%s/", concat_path) or ""
        end
      end,
      hl = { fg = "text", bg = "crust" },
    },
    {
      provider = function(self)
        if self.path:find("Scratch") then return string.format(" %s ", vim.bo.filetype) end

        return self.path_split and self.path_split[#self.path_split]
      end,
      hl = { fg = "text", bg = "crust", bold = true },
    },
  },
  -- File Flags
  {
    condition = function() return vim.bo.buftype ~= "terminal" end,
    {
      condition = function()
        local filename = vim.fn.expand("%")
        return filename ~= ""
          and filename:match("^%a+://") == nil
          and vim.bo.buftype == ""
          and vim.fn.filereadable(filename) == 0
      end,
      provider = " [New]",
      hl = { fg = "green" },
    },
    {
      condition = function() return vim.bo.modified end,
      provider = " ",
      hl = { fg = "peach" },
    },
    {
      condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
      provider = " ",
      hl = { fg = "red" },
    },
  },
}

---@diagnostic disable: undefined-field
M.Keystroke = {
  condition = function() return require("noice").api.status.command.has() end,
  provider = function() return (" %s "):format(require("noice").api.status.command.get()) end,
  hl = { fg = "mauve" },
}

---@diagnostic enable: undefined-field
M.MacroRecording = {
  condition = function() return vim.fn.reg_recording() ~= "" end,
  update = { "RecordingEnter", "RecordingLeave" },
  provider = function() return (" recording @%s "):format(vim.fn.reg_recording()) end,
  hl = { fg = "peach" },
}

M.LazyUpdate = {
  condition = require("lazy.status").has_updates,
  update = { "User", pattern = "LazyUpdate" },
  on_click = {
    callback = function()
      vim.defer_fn(function() vim.cmd("Lazy") end, 100)
    end,
    name = "update_plugins",
  },
  provider = function() return (" %s "):format(require("lazy.status").updates()) end,
  hl = { fg = "pink" },
}

M.Copilot = {
  static = {
    icon = {
      normal = " ",
      inprogress = " ",
      sleep = " ",
      warning = " ",
      disabled = " ",
      unknown = " ",
    },
    color = {
      [""] = "red",
      ["Normal"] = "lavender",
      ["Warning"] = "yellow",
      ["InProgress"] = "green",
      ["Disabled"] = "overlay2",
    },
  },
  condition = function() return Utils.is_loaded("copilot.lua") and U.copilot_attached end,
  {
    condition = function() return U.get_copilot_state() == "inprogress" end,
    update = { "User", pattern = "UpdateSpinner" },
    provider = function() return Snacks.util.spinner() end,
    hl = { fg = "green" },
  },
  {
    update = { "User", pattern = "UpdateCopilotStatus" },
    provider = function(self)
      local state = U.get_copilot_state()
      return (" %s "):format(self.icon[state])
    end,
    hl = function(self)
      if not U.is_enabled() then return { fg = self.color["Disabled"] } end

      local status = U.copilot_status.data.status
      return { fg = status and self.color[status] or self.color[""] }
    end,
  },
}

M.ActiveLSP = {
  static = { icon = " " },
  condition = C.lsp_attached,
  update = { "LspAttach", "LspDetach", "VimResized" },
  on_click = {
    callback = function()
      vim.defer_fn(function() vim.cmd("LspInfo") end, 100)
    end,
    name = "lsp_info",
  },
  flexible = 1,
  {
    provider = function(self)
      local attached = Utils.get_lsp_clients()

      if #attached == 0 then
        return ""
      elseif #attached == 1 then
        return (" %s%s "):format(self.icon, attached[1])
      end

      return (" %s[%s] "):format(self.icon, table.concat(attached, ", "))
    end,
  },
  {
    provider = function(self)
      local attached = Utils.get_lsp_clients()
      return #attached >= 1 and string.format(" %s%s LSP ", self.icon, #attached) or ""
    end,
  },
}

M.Ruler = {
  update = { "User", pattern = "ForceRedraw", callback = U.redraw() },
  M.Separator("", { fg = "surface0", bg = "crust" }),
  {
    init = U.update_events({ { "User", pattern = "ForceRedraw", callback = U.redraw() } }),
    provider = "  %l  %c ",
    hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
    update = { "CursorMoved", "CursorMovedI", "BufEnter" },
  },
  M.Separator("", function(self) return { fg = "surface0", bg = self:mode_color() } end),
}

M.Clock = {
  -- stylua: ignore
  static = {
    clock_icons = { "󱑋", "󱑌", "󱑍", "󱑎", "󱑏", "󱑐", "󱑑", "󱑒", "󱑓", "󱑔", "󱑕", "󱑖" },
  },
  init = U.update_events({
    { "User", pattern = "UpdateTime", callback = function() vim.cmd.redrawstatus() end },
  }),
  update = { "User", pattern = "ForceRedraw", callback = U.redraw() },
  {
    provider = function(self)
      local hour = os.date("%I")
      local icon = self.clock_icons[tonumber(hour)]

      return (" %s %s "):format(icon, os.date("%H:%M"))
    end,
    hl = function(self) return { fg = "mantle", bg = self:mode_color(), bold = true } end,
  },
}

-- ╭─────────────────────────────────────────────────────────╮
-- │             Terminal Statusline Components              │
-- ╰─────────────────────────────────────────────────────────╯

M.TerminalMode = {
  condition = function() return vim.bo.buftype == "terminal" end,
  provider = function(self) return ("  %s "):format(self:mode_name()) end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color() } end,
  M.Separator(
    "",

    function(self)
      return {
        fg = self:mode_color(),
        bg = not vim.b.term_title:find("term://") and "surface0" or "crust",
      }
    end,
    function() return not vim.b.term_title:find("term://") end,
    { "User", pattern = "ForceRedraw", callback = U.redraw() }
  ),
}

M.TermCwd = {
  init = U.update_events({ { "User", pattern = "ForceRedraw", callback = U.redraw() } }),
  condition = function() return not vim.b.term_title:find("term://") end,
  provider = function()
    local path = vim.b.term_title
    local folder = ""

    if path:find("term://") then return end

    if path:find("") then
      folder = ""
      path = path:gsub(" ", "")
    else
      folder = ""
    end

    path = vim.trim(vim.split(path, "-")[1])

    return (" %s %s "):format(folder, path)
  end,
  hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
}

local cmd_running = false
M.TermCommand = {
  condition = function()
    return not vim.b.term_title:find("term://") and #vim.split(vim.b.term_title, "-") > 1
  end,
  {
    provider = function() return cmd_running and Snacks.util.spinner() or "" end,
    update = { "User", pattern = "UpdateSpinner" },
    hl = { fg = "peach" },
  },
  {
    provider = function()
      local split = vim.split(vim.b.term_title, "-")

      if #split == 1 then
        cmd_running = false
        U.stop_spinner()
        return ""
      end

      local cmd = vim.trim(split[2])
      cmd_running = true
      U.start_spinner()
      return (" %s "):format(cmd)
    end,
  },
}

-- ╭─────────────────────────────────────────────────────────╮
-- │              Special Statusline Components              │
-- ╰─────────────────────────────────────────────────────────╯

M.SpecialMode = {
  static = {
    filetype = {
      lazy = "󰒲 Lazy",
      mason = " Mason",
      minifiles = " MiniFiles",
      ["minifiles-help"] = " MiniFiles",
      qf = "󰅖 Quickfix List",
      snacks_picker_list = "🍿Explorer",
      snacks_picker_input = "🍿Picker",
      snacks_picker_preview = "🍿Picker",
    },
  },
  update = { "User", pattern = "ForceRedraw", callback = U.redraw() },
  provider = function(self)
    local filetype = vim.bo.filetype
    local title = self.filetype[filetype]

    local picker = nil
    if filetype:match("snacks_picker*") then picker = Snacks.picker.get()[1] end

    if (filetype == "snacks_picker_input" or filetype == "snacks_picker_preview") and picker then
      local picker_title = picker.title or ""
      if picker_title ~= "" then return (" %s (%s) "):format(title, picker_title) end
    end

    if filetype == "qf" then
      if U.is_loclist() then title = " Location List" end
    end

    return (" %s "):format(title)
  end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color(), bold = true } end,
  M.Separator("", function(self) return { fg = self:mode_color(), bg = "surface0" } end),
}

M.SpecialInfo = {
  init = U.update_events({ { "User", pattern = "ForceRedraw", callback = U.redraw() } }),
  provider = function()
    local filetype = vim.bo.filetype
    if filetype:match("snacks_picker*") then return (" %s "):format(U.SpecialInfo.picker()) end

    return (" %s "):format(U.SpecialInfo[filetype]())
  end,
  hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
  M.Separator("", { fg = "surface0", bg = "crust" }),
}

return M
