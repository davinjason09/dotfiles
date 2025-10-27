local M = {}
local actions = require("custom.terminal.actions")
local state = require("custom.terminal.state")
local utils = require("custom.terminal.utils")
local config = state.config

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
  local a = Snacks.picker.util.align
  local ret = {}
  local k = item.item
  local id = id_to_icon(item.idx, #tostring(item.idx))
  local width = vim.api.nvim_win_get_width(picker.list.win.win)
  local icon = Snacks.util.icon(k.name:lower(), "file", { fallback = { file = " " } })

  ret[#ret + 1] = { icon, "@text" }
  ret[#ret + 1] = { k.name, "@text" }
  ret[#ret + 1] = { a(id, width - #k.name - 5, { align = "right" }), "@text" }

  return ret
end

local function find_term()
  local items = {}
  for id, term in pairs(state.term_bufs) do
    table.insert(items, {
      item = term,
      text = id .. " " .. Snacks.picker.util.text(term, { "name", "bufnr" }),
      title = id_to_icon(id, #tostring(id)) .. " " .. term.name,
      file = vim.api.nvim_buf_get_name(term.bufnr),
    })
  end
  return items
end

---@param picker snacks.Picker
local function setup_autocmd(picker)
  picker.preview.win:on("BufEnter", function() vim.cmd.startinsert() end)
  picker.preview.win:on(
    { "VimResized", "WinResized" },
    function() utils.switch_term_buf(state.last_term) end
  )
  picker.preview.win:on("TermClose", function(_, ev)
    -- NOTE:
    -- ignore exit code if less than 0 (e.g. -1)
    if type(vim.v.event) == "table" and vim.v.event.status > 0 then
      return Snacks.notify.error(
        "Terminal exited with code " .. vim.v.event.status .. ".",
        { title = "Terminal" }
      )
    end

    local _, term = utils.get_term("bufnr", ev.buf)
    local opts = term and term.opts or {} ---@type TermOpts

    if opts.persist then
      picker:close()
      return vim.api.nvim_buf_delete(ev.buf, { force = true })
    end

    state.term_bufs = vim.tbl_filter(function(t) return t.bufnr ~= ev.buf end, state.term_bufs)

    vim.schedule(function()
      if #state.term_bufs == 0 or opts.auto_close then
        state.last_term = nil
        return picker:close()
      else
        utils.cycle_term_buf("prev")
      end

      vim.cmd.checktime()
      picker:find()
    end)
  end)
end

---@param cmd? string | string[]
M.pick = function(cmd)
  Snacks.picker.pick({
    title = "Terminal",
    focus = "list",
    layout = config.picker_layout,
    format = format_item,
    finder = find_term,
    on_show = function(picker)
      picker:action("focus_preview")
      setup_autocmd(picker)

      local buf ---@type integer
      if cmd then
        buf = state.term_bufs[#state.term_bufs].bufnr
      else
        buf = state.last_term or state.term_bufs[1].bufnr
      end

      utils.switch_term_buf(buf)
    end,
    actions = actions.picker,
    preview = function(ctx)
      local cur_win = ctx.picker:current_win()

      if state.last_win == "input" and cur_win ~= "input" then
        local buf = state.last_term or state.term_bufs[ctx.item.idx].bufnr
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
    end,
    win = {
      input = { keys = config.keys.input },
      list = { keys = config.keys.list },
      preview = {
        minimal = true,
        fixbuf = false,
        noautocmd = true,
        keys = config.keys.preview,
      },
    },
  })
end

---@param cmd? string | string[]
M.open = function(cmd)
  local id, term = utils.get_term("cmd", { cmd })
  if cmd and not id then utils.add_term(cmd, nil, { auto_close = true }) end
  if #state.term_bufs == 0 then utils.add_term() end

  local picker = Snacks.picker.get()[1]
  if not picker then return M.pick(cmd) end

  if cmd then
    local buf = term and term.bufnr or state.term_bufs[#state.term_bufs].bufnr
    utils.switch_term_buf(buf)
  end
end

---@param cmd? string | string[]
M.toggle = function(cmd)
  local picker = Snacks.picker.get()[1]
  return picker and picker:close() or M.open(cmd)
end

return M
