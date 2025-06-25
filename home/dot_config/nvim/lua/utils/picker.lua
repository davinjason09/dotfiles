---@class Utils.picker
local M = {}

local Snacks = require("snacks")
local a = Snacks.picker.util.align

---@param str string
local function display_termcodes(str)
  return str:gsub(string.char(9), "<TAB>"):gsub("\6", "<C-F>"):gsub(" ", "<Space>")
end

M.options = function()
  local options = {}
  for _, v in pairs(vim.api.nvim_get_all_options_info()) do
    local ok, value = pcall(vim.api.nvim_get_option_value, v.name, {})
    if ok then
      v.value = value
      table.insert(options, v)
    end
  end

  table.sort(options, function(left, right) return left.name < right.name end)

  ---@param item snacks.picker.Item
  local function format_item(item)
    local ret = {}
    local k = item.item
    local type_spacing = 12 - #k.type - 2
    local scope_spacing = 11 - #k.scope - 2

    ret[#ret + 1] = { a(k.name, 20), "Keyword" }
    ret[#ret + 1] = { "[", "Delimiter" }
    ret[#ret + 1] = { k.type, "Type" }
    ret[#ret + 1] = { a("]", type_spacing), "Delimiter" }
    ret[#ret + 1] = { "[", "Delimiter" }
    ret[#ret + 1] = { k.scope, "Constant" }
    ret[#ret + 1] = { a("]", scope_spacing), "Delimiter" }
    ret[#ret + 1] = { display_termcodes(tostring(k.value)), "Text" }

    return ret
  end

  local items = vim.tbl_map(
    function(option)
      return {
        text = string.format(
          "%s %s %s %s",
          option.name,
          option.type,
          option.scope,
          display_termcodes(tostring(option.value))
        ),
        item = option,
      }
    end,
    options
  )

  Snacks.picker.pick({
    title = "Options",
    format = function(item, _) return format_item(item) end,
    items = items,
    layout = {
      hidden = { "preview" },
      layout = { width = 0.8, height = 0.5 },
    },
    confirm = {
      action = function(picker, selection)
        picker:close()

        local esc = ""
        if vim.fn.mode() == "i" then
          esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        end

        local keys = ""
        if selection.item.type == "boolean" then
          keys = string.format("%s:set %s!", esc, selection.item.name)
        else
          keys = string.format("%s:set %s=%s", esc, selection.item.name, selection.item.value)
        end

        vim.api.nvim_feedkeys(keys, "m", true)
      end,
    },
  })
end

M.terminal = function()
  local term_list = Snacks.terminal.list()
  local terms = {}
  local spacing = { 0, 0, 0 }

  if #term_list == 0 then
    vim.notify("No terminals found", vim.log.levels.WARN)
    return
  end

  for _, term in ipairs(term_list) do
    table.insert(terms, term)
  end
  table.sort(terms, function(left, right) return left.buf < right.buf end)

  ---@param item snacks.picker.Item
  local function format_item(item)
    local ret = {}
    local k = item.item
    local pos_spacing = spacing[3] - #k.pos - 2

    local current_buf = vim.api.nvim_get_current_buf()
    local alternate_buf = vim.fn.bufnr("#")
    local info = vim.fn.getbufinfo(k.buf)[1]
    local flags = {
      k.buf == current_buf and "%" or (k.buf == alternate_buf and "#" or ""),
      info.hidden and "h" or (#(info.windows or {}) > 0 and "a" or ""),
    }

    ret[#ret + 1] = { a(tostring(k.buf), spacing[1] + 2), "Constant" }
    ret[#ret + 1] = { a(table.concat(flags), 3), "NonText" }
    ret[#ret + 1] = { " ", "Keyword" }
    ret[#ret + 1] = { a(k.title, spacing[2] + 2), "Text" }
    ret[#ret + 1] = { " " }
    ret[#ret + 1] = { "[", "Delimiter" }
    ret[#ret + 1] = { k.pos, "Type" }
    ret[#ret + 1] = { a("]", pos_spacing + 2), "Delimiter" }
    ret[#ret + 1] = { k.cwd, "NonText" }

    return ret
  end

  local items = vim.tbl_map(function(term)
    local term_name = vim.api.nvim_buf_get_name(term.buf)
    local term_id = vim.b[term.buf].snacks_terminal.id
    local term_pos = term.opts.position --[[@as string]]
    local term_cwd = vim.b[term.buf].term_title
    local term_title = term.opts.title or ("%s:%s"):format(term_id, term_pos)

    spacing[1] = math.max(spacing[1], vim.api.nvim_strwidth(tostring(term.buf)))
    spacing[2] = math.max(spacing[2], vim.api.nvim_strwidth(term_title or ""))
    spacing[3] = math.max(spacing[3], vim.api.nvim_strwidth(term_pos) + 2)

    return {
      text = string.format("%s %s %s %s", term.buf, term_title, term_pos, term_cwd),
      item = {
        buf = term.buf,
        cwd = term_cwd,
        id = term_id,
        pos = term_pos,
        title = term_title,
      },
      file = term_name,
    }
  end, terms)

  Snacks.picker.pick({
    title = "Terminal",
    format = function(item, _) return format_item(item) end,
    items = items,
    layout = { preset = "dropdown" },
    preview = "file",
    win = { preview = { minimal = true } },
    confirm = {
      action = function(picker, selection)
        picker:close()

        for _, term in ipairs(term_list) do
          -- close any floating terminals if the selected terminal is also floating
          if term.opts.position == selection.item.pos and term.opts.position == "float" then
            vim.schedule(function() term:hide() end)
          end

          if term.buf == selection.item.buf then
            if term.closed then
              vim.schedule(function() term:toggle() end)
            else
              vim.schedule(function() term:focus() end)
            end
          end
        end
      end,
    },
  })
end

M.reload = function()
  local plugins = require("lazy").plugins()
  local plugin_names = vim.tbl_map(function(plugin) return plugin.name end, plugins)

  local items = vim.tbl_map(
    function(name)
      return {
        text = name,
        item = name,
      }
    end,
    plugin_names
  )

  Snacks.picker.pick({
    title = "Reload Plugins",
    format = "text",
    items = items,
    layout = { preset = "vscode" },
    confirm = {
      action = function(picker, selection)
        picker:close()
        local plugin_name = selection.item
        require("lazy").reload({ plugins = { plugin_name } })
      end,

M.chezmoi = function()
  local results = require("chezmoi.commands").list({
    args = {
      "--path-style",
      "absolute",
      "--include",
      "files",
      "--exclude",
      "externals",
    },
  })

  local items = {}
  for _, file in ipairs(results) do
    table.insert(items, {
      text = file,
      file = file,
    })
  end

  Snacks.picker.pick({
    title = "Chezmoi Files",
    items = items,
    confirm = function(picker, item)
      picker:close()
      require("chezmoi.commands").edit({
        targets = { item.text },
        args = { "--watch" },
      })
    end,
  })
end

return M
