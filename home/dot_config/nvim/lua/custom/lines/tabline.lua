local M = {}

local Comp = require("custom.lines.components")
local Common = require("custom.lines.common").components
local utils = require("heirline.utils")

M.buflist_cache = {}
M.min_width = 0

local get_bufs = function()
  return vim.tbl_filter(
    function(bufnr) return vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) end,
    vim.api.nvim_list_bufs()
  )
end

M.TablineFileName = {
  init = function(self)
    local filename = self.filename
    self.icon, self.color = Snacks.util.icon(filename, "file")
    self.color = Snacks.util.color(self.color)

    local max_name_len = (self.min_width - #self.icon - 5)
    filename = vim.fn.fnamemodify(self.filename, ":t")

    if self.dupes and self.dupes[filename] then
      filename = vim.fn.fnamemodify(self.filename, ":h:t") .. "/" .. filename
    end

    filename = filename == "" and "[No Name]" or filename

    if #filename > max_name_len then filename = filename:sub(1, max_name_len - 1) .. "…" end

    local diag_icons = Defaults.icons.diagnostics
    local diagnostic = ""
    if self.errors > 0 then
      diagnostic = diag_icons.ERROR
    elseif self.warnings > 0 then
      diagnostic = diag_icons.WARN
    elseif self.info > 0 then
      diagnostic = diag_icons.INFO
    end

    self.final_name = filename .. " " .. diagnostic
    self.pad = math.ceil((self.min_width - #self.final_name - #self.icon - 3) / 2)
  end,
  {
    provider = function(self) return (" %s%s"):format(string.rep(" ", self.pad), self.icon) end,
    hl = function(self) return { fg = self.color } end,
  },
  {
    provider = function(self) return ("%s%s "):format(self.final_name, string.rep(" ", self.pad)) end,
    hl = function(self)
      return { fg = self.text_hl, bold = self.is_active, italic = self.is_active }
    end,
  },
}

M.TablineFileNameBlock = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(self.bufnr) end,
  hl = function(self)
    if self.is_active then
      return { fg = "text", bg = "base" }
    elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
      return { fg = "overlay2", bg = "mantle" }
    else
      return { fg = "overlay2", bg = "mantle" }
    end
  end,
  on_click = {
    callback = function(_, minwid) vim.api.nvim_win_set_buf(0, minwid) end,
    minwid = function(self) return self.bufnr end,
    name = "heirline_tabline_buffer_callback",
  },
  M.TablineFileName,
}

M.TablineCloseButton = {
  condition = function(self)
    return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
  end,
  {
    provider = "",
    hl = function(self) return { fg = self.is_active and "red" or "surface2" } end,
    on_click = {
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
          vim.cmd.redrawtabline()
        end)
      end,
      minwid = function(self) return self.bufnr end,
      name = "heirline_tabline_close_buffer_callback",
    },
    { provider = " " },
  },
}

M.TablineFileFlags = {
  condition = function(self) return vim.api.nvim_get_option_value("modified", { buf = self.bufnr }) end,
  provider = " ",
  hl = { fg = "peach" },
}

M.TablineBufferBlock = {
  init = function(self)
    self.min_width = 22
    self.errors = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.INFO })

    self.text_hl = "text"
    if self.errors > 0 then
      self.text_hl = "red"
    elseif self.warnings > 0 then
      self.text_hl = "yellow"
    elseif self.info > 0 then
      self.text_hl = "sky"
    elseif self.hints > 0 then
      self.text_hl = "teal"
    end
  end,
  -- update = { "DiagnosticChanged", "BufEnter" },
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
    M.TablineFileNameBlock,
    M.TablineCloseButton,
    M.TablineFileFlags,
  },
  {
    provider = "",
    hl = function(self) return { bg = self.is_active and "base" or "mantle", fg = "crust" } end,
  },
}

M.BufferLine = utils.make_buflist(
  M.TablineBufferBlock,
  { provider = " ", hl = { fg = "overlay2" } },
  { provider = " ", hl = { fg = "overlay2" } },
  function() return M.buflist_cache end,
  false
)

M.Tabpage = {
  {
    provider = function(self) return " %" .. self.tabnr .. "T" .. self.tabnr .. " " end,
    hl = { bold = true },
  },
  hl = function(self) return self.is_active and "TabLine" or "TabLineSel" end,
  update = { "TabNew", "TabClosed", "TabEnter", "TabLeave", "WinNew", "WinClosed" },
}

M.TabpageClose = {
  provider = " %999X  %X",
  hl = "TabLine",
}

M.TabPages = {
  condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
  {
    provider = "%=",
  },
  utils.make_tablist(M.Tabpage),
  M.TabpageClose,
}

M.setup = function()
  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
    callback = function()
      vim.schedule(function()
        local buffers = get_bufs()
        for i, v in ipairs(buffers) do
          M.buflist_cache[i] = v
        end

        for i = #buffers + 1, #M.buflist_cache do
          M.buflist_cache[i] = nil
        end

        if #M.buflist_cache > 1 then
          vim.o.showtabline = 2
        elseif vim.o.showtabline ~= 1 then --otherwise it breaks startup screen
          vim.o.showtabline = 1
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
    callback = function()
      local counts = {}
      local dupes = {}
      local names = vim.tbl_map(
        function(bufnr) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t") end,
        get_bufs()
      )

      for _, name in ipairs(names) do
        counts[name] = (counts[name] or 0) + 1
      end

      for name, count in pairs(counts) do
        if count > 1 then dupes[name] = true end
      end

      ---@diagnostic disable-next-line: inject-field
      require("heirline").tabline.dupes = dupes
    end,
  })
end

return {
  Comp.Offset("left"),
  Comp.Misc.Tabline.Left,
  Comp.Macro,
  utils.make_buflist(
    Comp.Buffer,
    { provider = " ", hl = { fg = "overlay2" } },
    { provider = " ", hl = { fg = "overlay2" } },
    function() return require("custom.lines")._buflist_cache end,
    false
  ),
  Common.Align,
  Comp.Git.Status,
  Comp.TabPage,
  Comp.Misc.Tabline.Right,
  Comp.Offset("right"),
}
