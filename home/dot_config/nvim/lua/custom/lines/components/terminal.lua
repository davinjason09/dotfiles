local M = {}

local Comp = require("custom.lines.common").components
local U = require("custom.lines.utils")

M.state = {
  current_title = "",
  cmd_running = false,
}

M.Mode = {
  init = U.update_events({
    { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
  }),
  condition = function() return vim.bo.buftype == "terminal" end,
  provider = function(self) return ("  %s "):format(self:mode_name()) end,
  hl = function(self) return { fg = "mantle", bg = self:mode_color() } end,
  Comp.Separator2({
    icon = "",
    hl = function(self)
      return {
        fg = self:mode_color(),
        bg = not (vim.b.term_title or ""):find("term://") and "surface0" or "crust",
      }
    end,
    update = function()
      local term_title = vim.b.term_title or ""
      local changed = term_title ~= M.state.current_title
      M.state.current_title = term_title
      return changed
    end,
    init = { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
  }),
}

M.CWD = {
  update = { "ModeChanged", pattern = "*:*", callback = function() U.redraw() end },
  condition = function() return not (vim.b.term_title or ""):find("term://") end,
  provider = function()
    local path = vim.b.term_title or ""
    local folder = ""

    if path:find("term://") then return end

    if path:find("") then
      folder = ""
      path = path:gsub(" ", "")
    else
      folder = ""
    end

    path = vim.trim(vim.split(path, " - ", { plain = true })[1])

    return (" %s %s "):format(folder, path)
  end,
  hl = function(self) return { fg = self:mode_color(), bg = "surface0" } end,
}

M.Command = {
  condition = function()
    local title = vim.b.term_title or ""
    return not title:find("term://") and #vim.split(title, "-") > 1
  end,
  {
    provider = function() return M.state.cmd_running and Snacks.util.spinner() or "" end,
    update = { "User", pattern = "UpdateSpinner" },
    hl = { fg = "peach" },
  },
  {
    provider = function()
      local split = vim.split(vim.b.term_title, " - ", { plain = true })

      if #split == 1 then
        M.state.cmd_running = false
        U.stop_spinner()
        return ""
      end

      local cmd = vim.trim(split[2])
      cmd = vim.split(cmd, "%s%f[%-]")[1]
      if #cmd > 30 then cmd = cmd:sub(1, 29) .. "…" end

      M.state.cmd_running = true
      U.start_spinner()
      return (" %s "):format(cmd)
    end,
  },
}

M.Name = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
    self.path = vim.fn.fnamemodify(self.filename, ":.")
    self.path_split = vim.split(self.path, "/")
  end,
  {
    provider = function(self)
      self.icon, self.color = Snacks.util.icon(self.path_split[#self.path_split], "file")
      self.color = Snacks.util.color(self.color)
      return (" %s"):format(self.icon)
    end,
    hl = function(self) return { fg = self.color, bg = "crust" } end,
  },
  {
    provider = function(self) return self.path_split[#self.path_split] end,
    hl = { fg = "text", bg = "crust", bold = true },
  },
}

return M
