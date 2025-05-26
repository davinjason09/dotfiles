local M = {}

-- stylua: ignore
M.mode_colors = {
  n       = Defaults.palette.blue,
  i       = Defaults.palette.green,
  v       = Defaults.palette.mauve,
  V       = Defaults.palette.mauve,
  ["\22"] = Defaults.palette.mauve,
  c       = Defaults.palette.peach,
  s       = Defaults.palette.mauve,
  S       = Defaults.palette.mauve,
  ["\19"] = Defaults.palette.mauve,
  R       = Defaults.palette.red,
  r       = Defaults.palette.red,
  ["!"]   = Defaults.palette.peach,
}

---Get color based on mode and focussed state
---@param mode string   Mode name, see :h `mode()`
---@param focus boolean Focused state, true if the buffer is focused
---@return string       #Color name
function M.get_mode_color(mode, focus)
  local color = M.mode_colors[mode] or Defaults.palette.blue
  return focus and color or Defaults.palette.surface1
end

---Git diffs
---@param props { buf: number, win: number, focused: bool }
---@return { [1]: string, group: string }[]
function M.get_diff(props)
  local icons = { added = " ", changed = " ", removed = " " }
  local map = { added = "Add", changed = "Change", removed = "Delete" }
  local signs = vim.b[props.buf].gitsigns_status_dict
  local labels = {}

  if not signs then return labels end

  for name, icon in pairs(icons) do
    if tonumber(signs[name]) and signs[name] > 0 then
      local hl = props.focused and "GitSigns" .. map[name] or "Comment"
      table.insert(labels, { ("%s%s "):format(icon, signs[name]), group = hl })
    end
  end

  if #labels > 0 then
    table.insert(labels, 1, { " " })
    table.insert(labels, { "│", group = "Comment" })
  end
  return labels
end

---Get buffer diagnostics
---@param props { buf: number, win: number, focused: bool }
---@return { [1]: string, group: string }[]
function M.get_diagnostics(props)
  local icons = Defaults.icons.diagnostics
  local labels = {}

  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity] })

    if n > 0 then
      local hl = props.focused and "Diagnostic" .. severity or "Comment"
      table.insert(labels, { ("%s%d "):format(icon, n), group = hl })
    end
  end

  if #labels > 0 then
    table.insert(labels, 1, { " " })
    table.insert(labels, { "│", group = "Comment" })
  end
  return labels
end

---@alias Info { [1]: string, guifg: string }

---Get buffer info
---@param props { buf: number, win: number, focused: bool }
---@return { icon: Info, name: Info, modified: Info }
function M.file(props)
  local palette = Defaults.palette
  local buf_name = vim.api.nvim_buf_get_name(props.buf)

  local file_name = vim.fn.fnamemodify(buf_name, ":t")
  local file_hl = props.focused and palette.text or palette.overlay2
  if file_name == "" then file_name = "[No Name]" end

  local ft_icon, ft_hl = Snacks.util.icon(file_name, "file")
  ft_hl = props.focused and Snacks.util.color(ft_hl --[[@as string]]) or palette.surface1

  local modified = vim.bo[props.buf].modified
  local modified_icon = modified and " " or " "
  local modified_hl = props.focused and palette.peach or palette.overlay2

  return {
    icon = { ft_icon, guifg = ft_hl },
    name = { file_name, guifg = file_hl },
    modified = { modified_icon, guifg = modified_hl },
  }
end

return M
