local M = {}

local actions = require("custom.terminal.actions")
local state = require("custom.terminal.state")
local utils = require("custom.terminal.utils")
local config = state.config

---@param id integer
local function id_to_icon(id)
  local icons = { "󰎡", "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" }
  local icon = ""

  while id > 0 do
    local idx = id % #icons + 1
    icon = icons[idx] .. icon
    id = math.floor(id / #icons)
  end

  return icon
end

---@param item snacks.picker.Item
---@param picker snacks.Picker
local function format_item(item, picker)
  local ret = {}
  local k = item.item
  local id = id_to_icon(item.idx)
  local width = vim.api.nvim_win_get_width(picker.list.win.win)
  local icon = Snacks.util.icon(k.name:lower(), "file", { fallback = { file = " " } })
  local name = #k.name > width and k.name:sub(1, width - #id - 2 - 2) .. "…" or k.name

  ret[#ret + 1] = { icon, "@text" }
  ret[#ret + 1] = { name, "@text" }
  ret[#ret + 1] = {
    col = 0,
    virt_text = { { id .. " ", "@text" } },
    virt_text_pos = "right_align",
    hl_mode = "combine",
  }

  return ret
end

local function find_term()
  local items = {}

  for id, term in pairs(state.term_bufs) do
    if not vim.api.nvim_buf_is_valid(term.buf) then
      if not term.opts.persist then goto continue end

      local old_buf = term.buf
      term.buf = vim.api.nvim_create_buf(false, true)

      if state.last_term == old_buf then state.last_term = term.buf end
      utils.open_term(term)
    end

    local term_file = vim.api.nvim_buf_get_name(term.buf) or ""
    table.insert(items, {
      item = term,
      text = id .. " " .. Snacks.picker.util.text(term, { "name", "buf" }),
      title = id_to_icon(id) .. " " .. term.name,
      file = term_file,
    })

    ::continue::
  end

  return items
end

---@param picker snacks.Picker
local function setup_autocmd(picker)
  picker.preview.win:on("BufEnter", function()
    vim.cmd.nohl()
    vim.cmd.startinsert()
  end)
  picker.preview.win:on({ "VimResized", "WinResized" }, function() utils.switch_term_buf(state.last_term) end)
  picker.preview.win:on("TermClose", function(_, ev)
    -- NOTE: ignore exit code if less than 0 (e.g. -1)
    local is_error = false
    if type(vim.v.event) == "table" and vim.v.event.status > 0 then
      is_error = true
      Snacks.notify.error("Terminal exited with code " .. vim.v.event.status .. ".", { title = "Terminal" })
    end

    local _, term = utils.get_term("buf", ev.buf)
    local opts = term and term.opts or {} ---@type TermOpts

    if opts.persist then
      picker:close()

      if is_error then
        state.term_bufs = vim.tbl_filter(function(t) return t.buf ~= ev.buf end, state.term_bufs)
        state.last_term = nil
      end

      return vim.api.nvim_buf_delete(ev.buf, { force = true })
    end

    state.term_bufs = vim.tbl_filter(function(t) return t.buf ~= ev.buf end, state.term_bufs)

    if is_error then return end

    vim.schedule(function()
      if #state.term_bufs == 0 or opts.auto_close then
        state.last_term = nil
        return picker:close()
      else
        utils.cycle_term_buf("prev")
      end

      picker:find()
    end)
  end)
end

---@class snacks.picker.terminal.Config: snacks.picker.Config
---@field cmd? string|string[]
---@field finder fun(opts: snacks.picker.terminal.Config, ctx: snacks.picker.finder.ctx): snacks.picker.finder.result
M.source = {
  title = "Terminal",
  focus = "list",
  show_empty = true,
  layout = config.picker_layout,
  format = format_item,
  finder = find_term,
  on_show = function(picker)
    ---@diagnostic disable-next-line: inject-field
    picker.last_win = vim.fn.win_getid(vim.fn.winnr("#"))
    picker:action("focus_preview")
    setup_autocmd(picker)

    ---@cast picker.opts snacks.picker.terminal.Config
    local cmd = picker.opts.cmd
    local created_id, term = utils.get_term("cmd", { cmd })

    if cmd and not created_id then
      utils.add_term(cmd, nil, { auto_close = true })
    elseif cmd and term then
      state.last_term = term.buf
    end

    if #state.term_bufs == 0 then utils.add_term() end

    picker:find()
    utils.switch_term_buf(state.last_term or state.term_bufs[1].buf)
  end,
  on_close = function(picker)
    picker:action("restore_win")

    -- Clean buf that is deleted from the term list
    for i = #state.buf_to_clear, 1, -1 do
      vim.api.nvim_buf_delete(state.buf_to_clear[i], { force = true })
    end

    state.buf_to_clear = {}
    vim.cmd("checktime")
  end,
  actions = actions.picker,
  preview = function(ctx)
    local cur_win = ctx.picker:current_win()

    if state.last_win == "input" and cur_win ~= "input" then
      local buf = state.last_term or state.term_bufs[ctx.item.idx].buf
      utils.switch_term_buf(buf)

      local action = cur_win == "list" and "stopinsert" or "startinsert"
      vim.defer_fn(function() ctx.picker:action(action) end, 25)
    end

    -- HACK:
    -- When the input is unhidden, the preview pane doesn't get updated, so as a workaround we
    -- refresh the picker's list and then move the cursor to the current item.
    if state.last_win ~= "input" and cur_win == "input" then
      ctx.picker:find()
      ctx.picker.list:move(ctx.item.idx)
    end

    state.last_win = cur_win
    if cur_win ~= "input" then return end

    Snacks.picker.preview.file(ctx)
    ctx.preview:set_title("Previewing: " .. ctx.item.title)

    -- HACK:
    -- - If we ever use input to search and preview the terminal, `snacks_picker_loaded` field will
    --   be set to true as the buffer is being previewed. However, when we close the picker, this
    --   buffer will get deleted because the picker assume that it's part of the picker due to that
    --   field being set to true.
    -- - We don't want that, so we set the field to false here, after we done previewing it

    ---@cast ctx.buf integer
    vim.b[ctx.buf].snacks_picker_loaded = false
  end,
  win = {
    input = { keys = config.keys.input },
    list = { keys = config.keys.list },
    preview = {
      minimal = true,
      noautocmd = true,
      keys = config.keys.preview,
    },
  },
}

return M
