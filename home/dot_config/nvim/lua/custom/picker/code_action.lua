local M = {}

local ms = vim.lsp.protocol.Methods
local lsp_utils = require("custom.lsp.utils")

---@param n integer
---@param val string
---@return table
local function repeated_table(n, val)
  local empty_lines = {}
  for _ = 1, n do
    table.insert(empty_lines, val)
  end
  return empty_lines
end

---@param buf integer
---@param width integer
---@param height integer
---@param message string
local function no_preview(buf, width, height, message)
  local formatted = "  " .. message .. "  "
  local filler = ("╱"):rep(width)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, repeated_table(height, filler))

  local lines = {}
  if height == 1 then
    lines[1] = formatted
  else
    local spacer = (" "):rep(#formatted)
    for i = 1, math.min(height, 3) do
      lines[i] = i % 2 == 0 and formatted or spacer
    end
  end

  local ns = vim.api.nvim_create_namespace("snacks_no_preview")
  local col = math.floor((width - vim.api.nvim_strwidth(formatted)) / 2)
  local start_row = math.max(math.floor(height / 2) - 2, 0)

  for i, line in ipairs(lines) do
    vim.api.nvim_buf_set_extmark(buf, ns, start_row + i, 0, {
      virt_text = { { line, "Operator" } },
      virt_text_pos = "overlay",
      virt_text_win_col = col,
    })
  end
end

---@param item (lsp.Command|lsp.CodeAction)
local function get_start(item)
  if item.edit then
    local changes = item.edit.documentChanges or item.edit.changes
    if changes then
      for _, v in pairs(changes) do
        local edits = v.edits or v
        if edits[1] and edits[1].range then return edits[1].range.start.line end
      end
    end
  end

  if item.command and item.command.arguments then
    for _, arg in ipairs(item.command.arguments) do
      if type(arg) == "table" and arg.start and arg.start.line then return arg.start.line end
    end
  end

  return 0
end

---@param item lsp.CodeAction|lsp.Command
---@param total_offset integer
---@return table, integer
local function adjust_changes_offset(item, total_offset)
  local edit = item.edit
  if not edit then return item, total_offset end

  local changes = edit.documentChanges or edit.changes
  if not changes then return item, total_offset end

  local local_diff = 0
  for _, entry in pairs(changes) do
    local edits = entry.edits or entry
    if type(edits) == "table" then
      for i = 1, #edits do
        local e = edits[i]
        if e.range then
          local s_line, e_line = e.range.start.line, e.range["end"].line
          e.range.start.line = s_line + total_offset
          e.range["end"].line = e_line + total_offset

          local _, new_lines = e.newText:gsub("\n", "")
          local_diff = local_diff + (new_lines - (e_line - s_line))
        end
      end
    end
  end
  return item, total_offset + local_diff
end

---@alias Changes table<lsp.DocumentUri,lsp.TextEdit[]>
---@alias DocumentChanges (lsp.TextDocumentEdit|lsp.CreateFile|lsp.RenameFile|lsp.DeleteFile)[]

---@param action (lsp.Command|lsp.CodeAction)
---@return (Changes|DocumentChanges)?
local function find_changes(action)
  if not action or not action.edit then return nil end
  return action.edit.documentChanges or action.edit.changes
end

local icon_map = {
  quickfix = { "", "DiagnosticWarn" },
  others = { "", "DiagnosticWarn" },
  refactor = { "", "DiagnosticInfo" },
  ["refactor.move"] = { "󰪹", "DiagnosticInfo" },
  ["refactor.extract"] = { "", "DiagnosticError" },
  ["source.organizeImports"] = { "", "DiagnosticWarn" },
  ["source.fixAll"] = { "󰃢", "DiagnosticError" },
  ["source"] = { "", "DiagnosticError" },
  ["rename"] = { "󰑕", "DiagnosticWarn" },
  ["codeAction"] = { "", "DiagnosticWarn" },
}

---@param item snacks.picker.Item
local function format_item(item)
  local ret = {}
  local k = item.item

  local icon, hl = unpack(icon_map[item.kind])
  local split = vim.split(k.action.title:gsub("%(", "- ("), " - ", { plain = true })
  ret[#ret + 1] = { icon, hl }
  ret[#ret + 1] = { "  " }
  ret[#ret + 1] = { Snacks.picker.util.align(item.line, #item.buffer_loc + 1), "Constant" }
  ret[#ret + 1] = { split[1], "@text" }
  ret[#ret + 1] = { " " }
  ret[#ret + 1] = { split[2], "Include" }
  ret[#ret + 1] = { "  " }
  ret[#ret + 1] = { "[", "Special" }
  ret[#ret + 1] = { k.client.name, "Special" }
  ret[#ret + 1] = { "]", "Special" }

  return ret
end

---@param opts snacks.picker.code_action.Config
---@param ctx snacks.picker.finder.ctx
local function get_code_actions(opts, ctx)
  opts = opts or {}

  local L = require("snacks.picker.source.lsp")
  local mode = opts.mode or vim.api.nvim_get_mode().mode
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  local diff_fn = (vim.text and vim.text.diff) or vim.diff

  local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local current_content = table.concat(current_lines, "\n") .. "\n"

  local tmp_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, current_lines)

  local branch = ""
  ---@async
  ---@param cb async fun(item: snacks.picker.finder.Item)
  return function(cb)
    ctx.async:on("done", function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(tmp_buf) then vim.api.nvim_buf_delete(tmp_buf, { force = true }) end
      end)
    end)

    L.request(buf, ms.textDocument_codeAction, function(client)
      local params, range
      local encoding = client.offset_encoding

      if opts.range then
        local s = assert(opts.range.start, "range must have a `start` property")
        local e = assert(opts.range["end"], "range must have a `end` property")
        params = vim.lsp.util.make_given_range_params(s, e, buf, encoding)
        branch = "range"
        range = { s[1], e[1] }
      elseif mode == "v" or mode == "V" then
        local s = { vim.fn.getpos("'<")[2], vim.fn.getpos("'<")[3] }
        local e = { vim.fn.getpos("'>")[2], vim.fn.getpos("'>")[3] }
        params = vim.lsp.util.make_given_range_params(s, e, buf, encoding)
        branch = "visual"
        range = { s[2], e[2] }
      else
        params = vim.lsp.util.make_range_params(0, encoding)
        branch = "normal"
        range = opts.all and { 1, vim.fn.line("$") } or nil
      end

      ---@type lsp.CodeActionContext
      local context = opts.context and vim.deepcopy(opts.context) or {}
      context.triggerKind = context.triggerKind or vim.lsp.protocol.CodeActionTriggerKind.Invoked
      context.diagnostics = context.diagnostics or lsp_utils.get_line_diagnostics(buf, client, range)

      --- @cast params lsp.CodeActionParams
      params.context = context

      return params
    end, function(client, results, param)
      results = vim.tbl_isempty(results) and {} or vim.islist(results) and results or { results }
      results = Utils.dedup(results, { func = vim.json.encode }) ---@type (lsp.CodeAction|lsp.Command)[]

      vim.print(branch)
      table.sort(results, function(a, b) return get_start(a) < get_start(b) end)

      if #results == 0 then return vim.notify("No code actions available", vim.log.levels.INFO) end

      for _, act in ipairs(results) do
        local line = get_start(act)
        local item = {
          line = tostring(line),
          buffer_loc = tostring(#current_lines),
          kind = act.kind,
          text = ("%d %s [%s]"):format(line, act.title, client.name),
          item = { client = client, action = act, context = param.context, text = act.title },
        }

        local changes = find_changes(act)
        if changes then
          local diffs = {}
          for _, edits in pairs(changes) do
            vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, current_lines)
            vim.lsp.util.apply_text_edits(edits, tmp_buf, client.offset_encoding)

            local new_content = table.concat(vim.api.nvim_buf_get_lines(tmp_buf, 0, -1, false), "\n") .. "\n"
            table.insert(diffs, diff_fn(current_content, new_content, opts.diff))
          end

          item.diff = Snacks.picker.util.tpl(
            "diff --git a/{file} b/{file}\n--- {file}\n+++ {file}\n{diff}",
            { file = vim.fn.fnamemodify(file, ":."), diff = table.concat(diffs, "\n") }
          )
        end

        cb(item) ---@diagnostic disable-line: await-in-sync
      end
    end)
  end
end

---@class snacks.picker.code_action.Config: snacks.picker.Config
---@field all? boolean
---@field apply? boolean
---@field context? lsp.CodeActionContext
---@field mode? string
---@field range? {start: integer[], end: integer[]}
M.source = {
  title = "Code Action",
  finder = get_code_actions,
  layout = { preset = "dropdown" },
  preview = function(ctx)
    if ctx.item.diff then
      Snacks.picker.preview.diff(ctx)
    else
      ctx.preview:minimal()

      local win = ctx.preview.win.win
      local height = vim.api.nvim_win_get_height(win)
      local width = vim.api.nvim_win_get_width(win)

      ---@cast ctx.buf integer
      vim.bo[ctx.buf].modifiable = true
      no_preview(ctx.buf, width, height, "No preview available for this action")
      vim.bo[ctx.buf].modifiable = false
    end
  end,
  format = format_item,
  diff = {
    ctxlen = 4,
    ignore_cr_at_eol = true,
    ignore_whitespace_change_at_eol = true,
    indent_heuristic = true,
  },
  confirm = function(picker)
    local items = picker:selected({ fallback = true })

    local offset = 0
    for i = 1, #items do
      local it = items[i].item
      it.action, offset = adjust_changes_offset(it.action, offset)
      lsp_utils.code_action.apply_action(it.action, it.client, it.context, 0)
    end

    picker:close()
  end,
}

return M
