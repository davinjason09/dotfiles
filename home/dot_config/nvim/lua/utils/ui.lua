---@class Utils.ui
local M = {}

---Check if the current screen is small based on the default threshold
function M.is_small_screen()
  local height = vim.o.lines
  return height <= Defaults.small_screen_threshold
end

-- Optimized treesitter foldexpr
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filtype, don't bother checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then return "0" end

    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end

  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

---@type table<string, fun(details: string[], lines: string[]): string[], string[]>
local lang_parse = {
  lua = function(details, lines)
    local new_lines = {}

    if #details > 0 then
      table.insert(details, 1, "```lua")
      table.insert(details, "```")

      if #lines > 0 then
        local vimdoc_pat = { "%s>(.*)", "<" }
        local in_vimdoc = false

        for _, line in ipairs(lines) do
          local splits = {}
          local match_1 = line:match(vimdoc_pat[1])
          local match_2 = line:match(vimdoc_pat[2])
          local cur_line = line

          if match_2 then
            if not cur_line:find("<%w+>") and not cur_line:find("%w%s<%s%w") then
              splits = vim.split(cur_line, vimdoc_pat[2], { trimempty = true })
              table.insert(new_lines, " ```")
              in_vimdoc = false
            else
              table.insert(new_lines, " " .. cur_line)
              cur_line = ""
            end
          end

          cur_line = splits[#splits] or cur_line
          if match_1 then
            splits = vim.split(cur_line, vimdoc_pat[1], { trimempty = true })
            local split_1 = vim.trim(splits[1]:gsub("%s%s", " "))

            table.insert(new_lines, " " .. split_1)
            table.insert(new_lines, " ```" .. match_1)
            cur_line = splits[2] or ""
            in_vimdoc = true
          end

          if cur_line ~= "" then
            if not in_vimdoc then
              cur_line = cur_line:gsub("%s%s", " ")
              cur_line = vim.trim(cur_line)
            end
            table.insert(new_lines, " " .. cur_line)
          end
        end

        if lines[1] ~= "---" then table.insert(new_lines, 1, "---") end
      end
    end

    return details, new_lines
  end,
  typst = function(details, lines) return details, lines end,
  default = function(details, lines)
    if #details > 0 then
      local buf = vim.api.nvim_get_current_buf()
      table.insert(details, 1, string.format("```%s", vim.bo[buf].ft or ""))
      table.insert(details, "```")

      if #lines > 0 and lines[1] ~= "---" then table.insert(lines, 1, "---") end
    end
    return details, lines
  end,
}

---@param opts blink.cmp.CompletionDocumentationDrawOpts
---@return string[]
function M.parse_doc(opts)
  -- Modified from: https://github.com/OXY2DEV/nvim/blob/main/lua/plugins/lsp.lua#L168
  local ft = vim.bo.filetype

  local lines = {}
  if opts.item and opts.item.documentation then
    lines = vim.split(opts.item.documentation.value or "", "\n", { trimempty = true })
  end

  local details = vim.split(opts.item.detail or "", "\n", { trimempty = true })
  local parser = lang_parse[ft] or lang_parse.default
  details, lines = parser(details, lines)
  -- vim.print(lines)
  local combined_lines = vim.list_extend(details, lines)

  return combined_lines
end

return M
