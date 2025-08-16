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
  local id = id_to_icon(item.id, #tostring(#state.term_bufs))
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
      id = id,
      item = term,
      text = id .. " " .. Snacks.picker.util.text(term, { "name", "bufnr" }),
    })
  end
  return items
end

local function setup_autocmd()
  state.term_win:on("BufEnter", function() vim.cmd.startinsert() end)
  state.term_win:on("TermClose", function()
    if type(vim.v.event) == "table" and vim.v.event.status ~= 0 then
      return Snacks.notify.error("Terminal exited with code " .. vim.v.event.status .. ".")
    end

    local picker = assert(Snacks.picker.get()[1])
    local closed_buf = vim.api.nvim_get_current_buf()
    local _, term = utils.get_term("bufnr", closed_buf)
    local opts = term and term.opts or {} ---@type TermOpts

    if opts.persist then
      picker:close()
      vim.api.nvim_buf_delete(closed_buf, { force = true })
      return
    end

    state.term_bufs = vim.tbl_filter(function(t) return t.bufnr ~= closed_buf end, state.term_bufs)

    vim.schedule(function()
      if #state.term_bufs == 0 or opts.auto_close then
        state.last = nil
        picker:close()
        return
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
    format = function(item, picker) return format_item(item, picker) end,
    finder = find_term,
    on_show = function(picker)
      picker:action("focus_preview")
      state.term_win = picker.layout.wins.preview
      setup_autocmd()

      local buf ---@type integer
      if cmd then
        buf = state.term_bufs[#state.term_bufs].bufnr
      else
        buf = state.last or state.term_bufs[1].bufnr
      end

      utils.switch_term_buf(buf)
    end,
    actions = actions.picker,
    preview = function() return false end,
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
  if cmd then utils.add_term(cmd, nil, { auto_close = true }) end
  if #state.term_bufs == 0 then utils.add_term() end

  local picker = Snacks.picker.get()[1]
  if not picker then
    M.pick(cmd)
    return
  end

  if cmd then
    utils.switch_term_buf(state.term_bufs[#state.term_bufs].bufnr)
    picker:find()
  end
end

M.toggle = function(cmd)
  local picker = Snacks.picker.get()[1]
  if picker then
    picker:close()
  else
    M.open(cmd)
  end
end

return M
