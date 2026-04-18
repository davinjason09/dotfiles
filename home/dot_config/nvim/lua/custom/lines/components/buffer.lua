local U = require("custom.lines.utils")

local BufferName = {
  init = function(self)
    self.icon, self.color = Snacks.util.icon(self.filename, "file")
    self.color = Snacks.util.color(self.color)

    local buf_map = self.buf_map or {}
    self.bufname = buf_map[self.filename] or { parent = "", tail = "" }

    self.max_name_len = self.min_width - #self.icon
    local fullname = self.bufname.parent .. self.bufname.tail

    self.pad = math.floor((self.min_width - #fullname - #self.icon) / 2)
    if self.pad == 0 then self.pad = 1 end
  end,
  on_click = {
    callback = function(_, buf)
      if not vim.wo.winfixbuf then vim.api.nvim_win_set_buf(0, buf) end
    end,
    minwid = function(self) return self.bufnr end,
    name = "heirline_buffer_callback",
  },
  {
    provider = function(self) return (" %s%s"):format((" "):rep(self.pad), self.icon) end,
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
        sp = "sky",
        underline = self.is_active,
      }
    end,
  },
  {
    provider = function(self)
      local bufname = self.bufname.tail

      if #bufname > self.max_name_len then bufname = bufname:sub(1, self.max_name_len - 1) .. "…" end

      return ("%s %s%s "):format(bufname, self.diag_icon, (" "):rep(self.pad))
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
  fallthrough = false,
  {
    condition = function(self) return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr }) end,
    provider = "",
    hl = function(self) return { fg = self.is_active and "red" or "surface2", sp = "sky", underline = self.is_active } end,
    on_click = {
      callback = vim.schedule_wrap(function(_, buf)
        if vim.api.nvim_buf_is_valid(buf) then Snacks.bufdelete(buf) end
      end),
      minwid = function(self) return self.bufnr end,
      name = "heirline_close_buffer_callback",
    },
    { provider = " " },
  },
  -- If buffer has changes, notify user instead and don't show the close icon
  {
    provider = " ",
    hl = function(self) return { fg = "peach", sp = "sky", underline = self.is_active } end,
  },
}

return {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
    self.min_width = 20

    local diagnostic = vim.split(vim.diagnostic.status(self.bufnr), "[%s:%d]-%s-%%#%w-#", { trimempty = true })[1]

    self.text_hl, self.diag_icon = "text", ""
    self.has_diagnostic = diagnostic ~= nil
    if self.has_diagnostic then
      self.text_hl, self.diag_icon = self.icon_to_hl[diagnostic], diagnostic
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
    init = U.update_events({ { "User", pattern = "UpdateBufName", callback = function() U.redraw("tab") end } }),
    update = { "DiagnosticChanged", "BufEnter", "WinClosed", callback = function() U.redraw("tab") end },
    BufferName,
  },
  {
    update = { "BufModifiedSet", "BufEnter", "WinClosed" },
    BufferCloseButton,
  },
  {
    provider = "",
    hl = function(self) return { bg = self.is_active and "base" or "mantle", fg = "crust" } end,
  },
}
