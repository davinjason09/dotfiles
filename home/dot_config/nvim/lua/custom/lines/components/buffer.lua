local BufferName = {
  init = function(self)
    self.icon, self.color = Snacks.util.icon(self.filename, "file")
    self.color = Snacks.util.color(self.color)
    self.bufname = self.buf_map[self.filename] or { parent = "", tail = "" }

    self.max_name_len = self.min_width - #self.icon
    local fullname = self.bufname.parent .. self.bufname.tail

    self.pad = math.floor((self.min_width - #fullname - #self.icon) / 2)
    if self.pad == 0 then self.pad = 1 end
  end,
  on_click = {
    callback = function(_, minwid) vim.api.nvim_win_set_buf(0, minwid) end,
    minwid = function(self) return self.bufnr end,
    name = "heirline_buffer_callback",
  },
  {
    provider = function(self) return (" %s%s"):format(string.rep(" ", self.pad), self.icon) end,
    hl = function(self) return { fg = self.color } end,
  },
  {
    condition = function(self) return self.bufname.parent ~= "" end,
    provider = function(self) return self.bufname.parent end,
    hl = function(self)
      return {
        fg = (self.is_active or self.has_diagnostic) and self.text_hl or "surface1",
        bold = self.is_active,
        italic = self.is_active,
      }
    end,
  },
  {
    provider = function(self)
      local bufname = self.bufname.tail

      if #bufname > self.max_name_len then bufname = bufname:sub(1, self.max_name_len - 1) .. "…" end

      local icon = Defaults.icons.diagnostics[self.diag_type] or ""
      if icon ~= "" then icon = " " .. vim.trim(icon) end

      return ("%s%s%s "):format(bufname, icon, string.rep(" ", self.pad))
    end,
    hl = function(self)
      return {
        fg = (self.is_active or self.has_diagnostic) and self.text_hl or "overlay2",
        bold = self.is_active,
        italic = self.is_active,
      }
    end,
  },
}

local BufferCloseButton = {
  {
    condition = function(self) return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr }) end,
    provider = "",
    hl = function(self) return { fg = self.is_active and "red" or "surface2" } end,
    on_click = {
      callback = function(_, bufnr)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then Snacks.bufdelete(bufnr) end
          vim.cmd.redrawtabline()
        end)
      end,
      minwid = function(self) return self.bufnr end,
      name = "heirline_close_buffer_callback",
    },
    { provider = " " },
  },
  -- If buffer has changes, notify user instead and don't show the close icon
  {
    condition = function(self) return vim.api.nvim_get_option_value("modified", { buf = self.bufnr }) end,
    provider = " ",
    hl = { fg = "peach" },
  },
}

return {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
    self.min_width = 20

    self.info = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.INFO })
    self.hints = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.HINT })
    self.errors = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.WARN })

    self.has_diagnostic = (self.errors > 0 or self.warnings > 0 or self.info > 0 or self.hints > 0)
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
  hl = function(self)
    return {
      fg = self.is_active and "text" or "surface0",
      bg = self.is_active and "base" or "mantle",
      sp = "sky",
      underline = self.is_active,
    }
  end,
  {
    provider = "",
    hl = function(self) return { bg = self.is_active and "base" or "mantle", fg = "crust" } end,
  },
  {
    update = { "User", "DiagnosticChanged", "BufEnter", pattern = { "UpdateBufName", "UpdateDiagnostic", "*" } },
    BufferName,
  },
  {
    update = { "BufModifiedSet", "BufEnter" },
    BufferCloseButton,
  },
  {
    provider = "",
    hl = function(self) return { bg = self.is_active and "base" or "mantle", fg = "crust" } end,
  },
}
