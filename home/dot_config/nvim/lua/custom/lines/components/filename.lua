local U = require("custom.lines.utils")

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
    self.path = U.pretty_path(self.filename, { type = "relative", split = true })
    self.parents_shorten = vim.fs.dirname(vim.fn.pathshorten(vim.fs.relpath(".", self.filename)))
  end,
  hl = function(self) return { fg = self.text_hl, bg = "crust" } end,
  {
    flexible = 1,
    condition = function() return vim.bo.filetype ~= "help" end,
    { provider = function(self) return self.filename:find("scratch") ~= nil and "[Scratch] " or self.path.parents end },
    { provider = function(self) return self.parents_shorten end },
    { provider = function(self) return vim.fn.pathshorten(self.path.parents) end },
  },
  {
    condition = function(self) return self.path.parents ~= "" and self.path.basename ~= "[No Name]" end,
    provider = "/",
  },
  {
    provider = function(self) return self.path.basename end,
    hl = { bold = true },
  },
}

local FileInfo = {
  {
    condition = function(self) return self.has_diagnostic end,
    provider = function(self) return (" %s"):format(self.diag_icon) end,
    hl = function(self) return { fg = self.text_hl } end,
  },
  {
    condition = function(self)
      return self.filename ~= ""
        and not self.filename:match("^%a+://")
        and vim.bo.buftype == ""
        and vim.fn.filereadable(self.filename) == 0
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

    local diagnostic = vim.split(vim.diagnostic.status(self.bufnr), "[%s:%d]-%s-%%#%w-#", { trimempty = true })[1]

    self.text_hl, self.diag_icon = "text", ""
    self.has_diagnostic = diagnostic ~= nil
    if self.has_diagnostic then
      self.text_hl, self.diag_icon = self.icon_to_hl[diagnostic], diagnostic
    end
  end,
  {
    update = { "BufEnter", "BufModifiedSet" },
    FileIcons,
  },
  {
    update = { "DiagnosticChanged", "BufEnter", callback = function() U.redraw("stl") end },
    FilePrettyPath,
  },
  {
    update = { "DiagnosticChanged", "BufEnter", "BufModifiedSet", callback = function() U.redraw("stl") end },
    FileInfo,
  },
}
