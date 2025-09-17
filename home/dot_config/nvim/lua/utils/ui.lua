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
  return M.have(vim.b[buf].filetype) and vim.treesitter.foldexpr() or "0"
end

---@type table<string, fun(details: string[], lines: string[]): string[], string[]>
local lang_parse = {
  lua = function(details, lines)
    local new_lines = {}

    if #details > 0 then
      table.insert(details, 1, "```lua")
      table.insert(details, "```")
    end

    -- TODO: make this logic actually readable
    if #lines > 0 then
      local vimdoc_pat = { "%s>(.*)", "<" }
      local in_vimdoc = false
      local in_lua_block = false

      for _, line in ipairs(lines) do
        local splits = {}
        local match_1 = line:match(vimdoc_pat[1])
        local match_2 = line:match(vimdoc_pat[2])
        local cur_line = line

        -- skip for lua codeblocks
        if line:match("^%s*```lua") then
          table.insert(new_lines, line)
          in_lua_block = true
        elseif line:match("^%s*```") and in_lua_block then
          table.insert(new_lines, line)
          in_lua_block = false
        elseif in_lua_block then
          table.insert(new_lines, line)
          cur_line = ""
        else
          if match_2 then
            if
              (not cur_line:find("\\?<[%w%-]+>") and not cur_line:find("[%w%]%)]%s<[%<%=]*%s%w"))
              or cur_line:find("^%s*<%s-%w")
            then
              splits = vim.split(cur_line, vimdoc_pat[2], { trimempty = true })
              table.insert(new_lines, "```")
              cur_line = vim.trim(splits[1]) .. table.concat(splits, "<", 2)
              in_vimdoc = false
            else
              table.insert(new_lines, cur_line)
              cur_line = ""
            end
          end

          -- cur_line = splits[#splits] or cur_line
          if match_1 then
            if not cur_line:find("[%w%]%)]%s>[%>%=]?%s%w") then
              splits = vim.split(cur_line, vimdoc_pat[1], { trimempty = true }) or {}
              local split_1 = splits[1] and vim.trim(splits[1]:gsub("%.%s%s", " ")) or ""

              table.insert(new_lines, " " .. split_1)
              table.insert(new_lines, "```" .. match_1)
              cur_line = table.concat(splits, " >", 2) or ""
              in_vimdoc = true
            end
          end

          if cur_line ~= "" then
            if not in_vimdoc then
              if cur_line:sub(1, 2) ~= "  " then
                cur_line = " " .. vim.trim(cur_line:gsub("%s%s", " "))
              end
              cur_line = cur_line:gsub("|([%w%(%)%-:_]+)|", "`|%1|`")
              if cur_line:find("%-%-%-$") then cur_line = cur_line:gsub("%-%-%-", "___") end
            end
            table.insert(new_lines, cur_line)
          end
        end
      end

      if in_vimdoc then table.insert(new_lines, "```") end
      if lines[1] ~= "---" and #details > 0 then table.insert(new_lines, 1, "---") end
    end

    return details, new_lines
  end,
  typst = function(details, lines)
    local pattern = "%((.*)%) => (%w+)"
    local new_lines = nil

    if #details > 0 then
      local args, item = details[1]:match(pattern)
      new_lines = {}

      if args and item then
        table.insert(new_lines, "```typst")
        table.insert(new_lines, ("#let %s("):format(item))

        local args_list = vim.split(args, ", ", { trimempty = true })
        for _, arg in ipairs(args_list) do
          if #arg > 80 then
            local arg_split = vim.split(arg, " | ", { trimempty = true })
            local first_arg = arg:match("(%w+):")

            table.insert(new_lines, "  " .. arg_split[1])
            for i = 2, #arg_split do
              table.insert(
                new_lines,
                ("  %s| %s"):format(string.rep(" ", #first_arg), arg_split[i])
              )
            end
            new_lines[#new_lines] = new_lines[#new_lines] .. ","
          else
            table.insert(new_lines, "  " .. arg .. ",")
          end
        end

        table.insert(new_lines, ");")
        table.insert(new_lines, "```")

        details = new_lines
      end
    end
    return details, lines
  end,
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
  -- vim.print("Before:", opts.item.documentation.value, opts.item.detail)
  local parser = lang_parse[ft] or lang_parse.default
  details, lines = parser(details, lines)
  -- vim.print("After:", { details = details, lines = lines })
  local combined_lines = vim.list_extend(details, lines)

  return combined_lines
function M.indentexpr()
  local buf = vim.api.nvim_get_current_buf()
  return M.have(vim.b[buf].filetype) and require("nvim-treesitter").indentexpr() or -1
end

---Add powerline symbols to the title of popups
---@alias title_opts { msg: string, views?: string, kind?: string }
---@param opts title_opts
function M.noice_title(opts)
  opts.views = opts.views or "cmdline_popup"

  local powerline_hl = ""
  if opts.views == "confirm" then
    powerline_hl = "NoiceConfirmBorder"
  elseif opts.kind then
    powerline_hl = "NoiceCmdlinePopupBorder" .. opts.kind:sub(1, 1):upper() .. opts.kind:sub(2)
  end

  return {
    { "", powerline_hl },
    { opts.msg },
    { "", powerline_hl },
  }
end

M.installed_parser = {}

function M.have(ft)
  local lang = vim.treesitter.language.get_lang(ft)
  return vim.tbl_contains(M.installed_parser, lang)
end
return M
