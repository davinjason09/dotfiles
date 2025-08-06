---@class Utils.terminal
local M = {}

---@alias TermOpts { persist?: boolean, auto_close?: boolean }
---@alias TermBuf { bufnr: number, name: string, cmd?: string | string[], opts?: TermOpts }

---@param cmd string | string[]
---@param opts? table
---@return integer
local function jobstart(cmd, opts)
  opts = opts or {}
  return vim.fn.jobstart(cmd, vim.tbl_isempty(opts) and vim.empty_dict() or opts)
end

---@type { term_bufs: TermBuf[], last: integer?, term_win: snacks.win? }
M.state = {
  last = nil,
  term_bufs = {},
  term_win = nil,
}

---@param key string
---@param value any
M.get_term = function(key, value)
  for idx, term in ipairs(M.state.term_bufs) do
    if term[key] == value then return idx, term end
  end

  return nil
end

---@param cmd (string | string[])?
---@param name string?
---@param opts TermOpts?
M.add_term = function(cmd, name, opts)
  if not M.state.term_bufs then M.state.term_bufs = {} end

  opts = vim.tbl_extend("force", { persist = false, auto_close = false }, opts or {})
  local term_name = cmd and (type(cmd) == "table" and cmd[1] or cmd) or name or "Terminal" --[[@as string]]
  term_name = term_name:sub(1, 1):upper() .. term_name:sub(2)

  local term_buf = {
    bufnr = vim.api.nvim_create_buf(false, true),
    cmd = Snacks.terminal.parse(cmd or vim.o.shell), ---@diagnostic disable-line: invisible
    name = term_name,
    opts = opts,
  }

  table.insert(M.state.term_bufs, term_buf)
end

---@param buf integer
M.switch_term_buf = function(buf)
  local picker = Snacks.picker.get()[1]
  if not picker then return Snacks.notify.error("Picker not found") end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      local id, term = assert(M.get_term("bufnr", buf))
      local opts = term.opts or {} ---@type TermOpts
      if opts.persist then
        buf = vim.api.nvim_create_buf(false, true)
        M.state.term_bufs[id].bufnr = buf
        picker:find()
      end
    end

    M.state.last = buf
    M.state.term_win:set_buf(buf)
    M.state.term_win:map()

    local details = vim.iter(M.state.term_bufs):find(function(x) return x.bufnr == buf end)
    picker.preview.title = details.name
    picker:update_titles()

    if vim.bo[buf].buftype ~= "terminal" then
      local cur_win = picker:current_win()
      local is_term = cur_win == "terminal"
      if not is_term then picker:action("focus_term") end

      jobstart(details.cmd, { term = true })

      if not is_term then picker:action(("focus_%s"):format(cur_win)) end
    end
  end)
end

---@param dir "prev" | "next"
M.cycle_term_buf = function(dir)
  local cur_idx = M.get_term("bufnr", M.state.last)
  if not cur_idx then
    M.switch_term_buf(M.state.term_bufs[1].bufnr)
    return
  end

  local new_idx = (cur_idx + (dir == "prev" and -2 or 0)) % #M.state.term_bufs
  local next_buf = M.state.term_bufs[new_idx + 1].bufnr
  M.switch_term_buf(next_buf)
end

---@param cmd string | string[] | nil
M.open = function(cmd)
  if cmd then M.add_term(cmd, nil, { auto_close = true }) end
  if #M.state.term_bufs == 0 then M.add_term() end

  ---@type snacks.win.Config
  local term_win_opts = {
    relative = "editor",
    noautocmd = true,
    bo = {
      bufhidden = "wipe",
      buftype = "nofile",
      buflisted = false,
      swapfile = false,
      undofile = false,
      modifiable = false,
    },
    wo = { winhighlight = Snacks.picker.highlight.winhl("SnacksPicker") },
    minimal = true,
    footer_pos = "center",
    fixbuf = false,
    actions = {
      focus_list = function()
        local picker = Snacks.picker.get()[1]
        if not picker then return end

        picker:action("focus_list")
      end,
      close = function()
        local picker = Snacks.picker.get()[1]
        if not picker then return end

        picker:close()
      end,
      cycle_next = function() M.cycle_term_buf("next") end,
      cycle_prev = function() M.cycle_term_buf("prev") end,
      term_normal = function(self)
        self.esc_timer = self.esc_timer or assert(vim.uv.new_timer()) ---@diagnostic disable-line: inject-field

        if self.esc_timer:is_active() then
          self.esc_timer:stop()
          vim.cmd("stopinsert")
        else
          self.esc_timer:start(200, 0, function() end)
          vim.api.nvim_exec_autocmds("User", { pattern = "ForceRedraw", modeline = false })
          return "<ESC>"
        end
      end,
      goto_file = function(self)
        local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
        if f ~= "" then
          Snacks.notify.warn("No file under cursor")
        else
          self:close()
          vim.schedule(function() vim.cmd("e " .. f) end)
        end
      end,
    },
    keys = {
      ["q"] = "close",
      ["<C-`>"] = { "close", mode = { "n", "t", "i" } },
      ["<C-h>"] = { "focus_list", mode = { "n", "t", "i" } },
      ["<C-j>"] = { "cycle_next", mode = { "n", "t", "i" } },
      ["<C-k>"] = { "cycle_prev", mode = { "n", "t", "i" } },
      ["<ESC>"] = { "term_normal", mode = { "t" }, expr = true },
      ["gf"] = { "goto_file" },
    },
  }

  M.state.term_win = Snacks.win(term_win_opts)
  M.state.term_win:on("BufEnter", function() vim.cmd.startinsert() end)
  M.state.term_win:on("TermClose", function()
    if type(vim.v.event) == "table" and vim.v.event.status ~= 0 then
      return Snacks.notify.error("Terminal exited with code " .. vim.v.event.status .. ".")
    end

    local picker = Snacks.picker.get()[1]
    local closed_buf = vim.api.nvim_get_current_buf()
    local _, term = M.get_term("bufnr", closed_buf)
    local opts = term and term.opts or {} ---@type TermOpts

    if opts.persist then
      picker:close()
      vim.api.nvim_buf_delete(closed_buf, { force = true })
      return
    end

    M.state.term_bufs = vim.tbl_filter(
      function(t) return t.bufnr ~= closed_buf end,
      M.state.term_bufs
    )

    vim.schedule(function()
      if #M.state.term_bufs == 0 or opts.auto_close then
        M.state.last = nil
        picker:close()
        return
      else
        M.cycle_term_buf("prev")
      end

      vim.cmd.checktime()
      picker:find()
    end)
  end)

  local picker_layout = {
    layout = {
      box = "horizontal",
      width = 0.9,
      min_width = 80,
      height = 0.9,
      {
        box = "vertical",
        border = "rounded",
        width = 25,
        min_width = 25,
        title = "{live} {flags}",
        { win = "input", height = 1, border = "bottom" },
        { win = "list" },
      },
      { win = "terminal", title = "{preview}", border = "rounded" },
    },
    wins = { terminal = M.state.term_win },
  }

  local function id_to_icon(id, len)
    local icons = { "󰎡", "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" }
    local icon = ""

    while id > 0 do
      local idx = id % #icons + 1
      icon = icons[idx] .. icon
      id = math.floor(id / #icons)
    end

    return string.rep(icons[1], len - #icon) .. icon
  end

  ---@type snacks.picker.format
  local function format_item(item, picker)
    local width = vim.api.nvim_win_get_width(picker.list.win.win)
    local space = width

    local a = Snacks.picker.util.align
    local ret = {}
    local k = item.item
    local id = id_to_icon(item.id, #tostring(#M.state.term_bufs))
    local icon = Snacks.util.icon(k.name:lower(), "file", { fallback = { file = " " } })

    ret[#ret + 1] = { icon, "@text" }
    ret[#ret + 1] = { k.name, "@text" }
    ret[#ret + 1] = { a(id, space - #k.name - 5, { align = "right" }), "@text" }

    return ret
  end

  Snacks.picker.pick({
    title = "Terminal",
    focus = "list",
    layout = picker_layout,
    format = function(item, picker) return format_item(item, picker) end,
    finder = function()
      local items = {}
      for id, term in pairs(M.state.term_bufs) do
        table.insert(items, {
          id = id,
          item = term,
          text = id .. " " .. Snacks.picker.util.text(term, { "name", "bufnr" }),
        })
      end
      return items
    end,
    on_show = function(picker)
      picker:action("focus_term")

      local buf ---@type integer
      if cmd then
        buf = M.state.term_bufs[#M.state.term_bufs].bufnr
      else
        buf = M.state.last or M.state.term_bufs[1].bufnr
      end

      M.switch_term_buf(buf)
    end,
    actions = {
      confirm = function(picker, item)
        picker:action("focus_term")
        M.switch_term_buf(item.item.bufnr)
      end,
      focus_term = function(picker)
        local layout = picker.layout
        local w = layout.wins.terminal
        local ret ---@type snacks.win?

        if w and w:valid() and not layout:is_hidden("terminal") then ret = w end

        if ret then ret:focus() end
      end,
      add_term = function(picker)
        M.add_term()
        picker:find()
      end,
      add_term_cmd = function(picker)
        local term_cmd = vim.fn.input("Command: ")
        M.add_term(term_cmd, nil, { persist = true })
        picker:find()
      end,
      delete_term = function(picker)
        local term_bufs = picker:selected({ fallback = true })
        for id, item in pairs(term_bufs) do
          local term_buf = item.item.bufnr
          local idx = M.get_term("bufnr", term_buf)

          if idx then
            if M.state.last == term_buf then
              vim.schedule(function() M.cycle_term_buf("prev") end)
            end
            table.remove(M.state.term_bufs, idx)
          else
            Snacks.notify.error("Terminal not found: " .. id .. " " .. term_buf)
          end
        end

        if #M.state.term_bufs == 0 then
          picker:close()
        else
          picker.list:set_selected()
          picker.list:set_target()
          picker:find()
        end

        vim.schedule(Utils.edit.escape)
      end,
      edit_term_name = function(picker, item)
        local idx = M.get_term("bufnr", item.item.bufnr)

        if idx then
          local new_name = vim.fn.input("New Terminal Name: ", item.item.name)
          M.state.term_bufs[idx].name = new_name
          picker:find()

          if M.state.term_bufs[idx].bufnr == M.state.last then
            picker.preview.title = new_name
            picker:update_titles()
          end
        else
          Snacks.notify.error("Terminal not found")
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-`>"] = { "close", mode = { "n", "i" } },
          ["<C-j>"] = { "focus_list", mode = { "n", "i" } },
          ["<C-l>"] = { "focus_term", mode = { "n", "i" } },
          ["d"] = { "delete_term", desc = "Delete Terminal" },
          ["a"] = { "add_term", desc = "Add Terminal" },
          ["A"] = { "add_term_cmd", desc = "Add Terminal with Command" },
          ["e"] = { "edit_term_name", desc = "Edit Terminal Name" },
        },
      },
      list = {
        keys = {
          ["<C-`>"] = { "close", mode = { "n", "i" } },
          ["<C-k>"] = { "focus_input" },
          ["<C-l>"] = { "focus_term" },
          ["a"] = { "add_term", desc = "Add Terminal" },
          ["A"] = { "add_term_cmd", desc = "Add Terminal with Command" },
          ["d"] = { "delete_term", desc = "Delete Terminal" },
          ["e"] = { "edit_term_name", desc = "Edit Terminal Name" },
        },
      },
    },
  })
end

return M
