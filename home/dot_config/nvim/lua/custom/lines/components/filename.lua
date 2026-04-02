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
    condition = function(self) return self.has_diagnostic end,
    provider = function(self) return (" %s"):format(self.diag_icon) end,
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

    local diagnostic = vim.split(vim.diagnostic.status(self.bufnr), "[%s:%d]-%s-%%#%w-#", { trimempty = true })[1]
    local icon_hl = { [""] = "red", [""] = "teal", [""] = "sky", [""] = "yellow" }

    self.text_hl, self.diag_icon = "text", ""
    self.has_diagnostic = diagnostic ~= nil
    if self.has_diagnostic then
      self.text_hl, self.diag_icon = icon_hl[diagnostic], diagnostic
    end
  end,
  {
    update = { "BufEnter", "BufModifiedSet" },
    FileIcons,
  },
  {
    update = { "User", "BufEnter", pattern = { "UpdateDiagnostic", "*" } },
    FilePrettyPath,
  },
  {
    update = { "BufEnter", "BufModifiedSet" },
    FileInfo,
  },
}
