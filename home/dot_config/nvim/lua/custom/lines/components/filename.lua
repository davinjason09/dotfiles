local FileIcons = {
  init = function(self)
    self.icon, self.color = Snacks.util.icon(self.filename, "file")
    self.color = Snacks.util.color(self.color)
  end,
  provider = function(self) return (" %s"):format(self.icon) end,
  hl = function(self) return { fg = self.color, bg = "crust" } end,
}

local FilePrettyPath = {
  init = function(self)
    local U = require("custom.lines.utils")
    self.path = U.pretty_path(self.filename, "relative")
    self.path_split = vim.split(self.path, "/")
  end,
  {
    condition = function() return vim.bo.filetype ~= "help" end,
    provider = function(self)
      if self.path == "" then return "[No Name]" end
      if self.path:find("scratch") then return "[Scratch] " end
      if #self.path_split == 1 then return "" end
      return table.concat(self.path_split, "/", 1, #self.path_split - 1) .. "/"
    end,
    hl = function(self) return { fg = self.text_hl, bg = "crust" } end,
  },
  {
    provider = function(self) return self.path_split[#self.path_split] end,
    hl = function(self) return { fg = self.text_hl, bg = "crust", bold = true } end,
  },
}

local FileInfo = {
  {
    condition = function(self)
      return (self.errors > 0 or self.warnings > 0 or self.hints > 0 or self.info > 0)
    end,
    provider = function(self)
      local icon = Defaults.icons.diagnostics[self.diag_type] or ""
      return ("%s%s"):format(icon ~= "" and " " or "", vim.trim(icon))
    end,
    hl = function(self) return { fg = self.text_hl } end,
  },
  {
    condition = function()
      local filename = vim.fn.expand("%")
      return filename ~= ""
        and not filename:match("^%a+://")
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
}

return {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)

    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

    self.text_hl = "text"
    self.diag_type = ""
    if self.errors > 0 then
      self.text_hl = "red"
      self.diag_type = "ERROR"
    elseif self.warnings > 0 then
      self.text_hl = "yellow"
      self.diag_type = "WARN"
    elseif self.info > 0 then
      self.text_hl = "sky"
      self.diag_type = "INFO"
    elseif self.hints > 0 then
      self.text_hl = "teal"
    end
  end,
  update = { "DiagnosticChanged", "BufEnter", "BufModifiedSet" },
  FileIcons,
  FilePrettyPath,
  FileInfo,
}
