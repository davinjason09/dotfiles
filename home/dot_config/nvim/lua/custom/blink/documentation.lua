local M = {}

---@type table<string, fun(details: string, docs: string): string[], string[]>
local lang_parse = {
  lua = function(details, docs)
    details = vim.split(details --[[@as string]], "\n", { trimempty = true })

    if #details > 0 then
      table.insert(details, 1, "```lua")
      table.insert(details, "```")
    end

    docs = docs
      :gsub("|([^%s|]+)|", "`%1`")
      :gsub("%-%-%-", "___")
      :gsub("([%.%~%:])\n```lua", "%1\n\n```lua")
      :gsub("\n+%s*<(%s*[%[%]%{%}%(%)\"'%~%/%w%`%-%.%:%,%*]+)%s", "\n<\n%1 ")
      :gsub("\n+%s*<(%s*[%[%]%{%}%(%)\"'%~%/%w%`%-%.%:%,%*]+)$", "\n<\n%1")
      :gsub("\n+%s*<%s+>", "\n<\n>")
      :gsub("%s+>(%l*)\n+", "\n\n```%1\n")
      :gsub("\n+<\n+", "\n```\n\n")
      :gsub("\n+%s*<$", "\n```\n")
      :gsub("\n+%s*<(%s+<[%u%l%-]+>)", "\n```\n\n%1") -- Special case for <CTRL-...>
    docs = vim.split(docs --[[@as string]], "\n", { trimempty = true })

    if not vim.tbl_isempty(docs) and docs[1] ~= "___" and #details > 0 then table.insert(docs, 1, "___") end

    -- stylua: ignore start
    local INC_INDENT = {
      ["if"]    = true, ["else"] = true, ["elseif"]   = true, ["for"]   = true, ["try"] = true,
      ["while"] = true, ["func"] = true, ["function"] = true, ["catch"] = true,
    }
    local DEC_INDENT = {
      ["else"]   = true, ["elseif"]   = true, ["catch"]  = true, ["end"]     = true, ["endif"]       = true,
      ["endfor"] = true, ["endwhile"] = true, ["endtry"] = true, ["endfunc"] = true, ["endfunction"] = true,
    }
    -- stylua: ignore end

    local indent = 2
    local is_code = false
    local unclosed = {}
    local lang = nil
    for i, line in ipairs(docs) do
      if line:match("```") then
        is_code = not is_code
        indent = 2

        local cur_lang = line:match("```(%w+)")
        if cur_lang and not lang and is_code then
          lang = cur_lang
        elseif cur_lang and lang then
          table.insert(unclosed, i)
        end

        if not is_code then lang = nil end
      elseif is_code then
        local word = line:match("^%s*([%w]+)")

        if word and DEC_INDENT[word] or line:find("^%s*}") then indent = math.max(2, indent - 2) end

        docs[i] = line:gsub("^%s+", (" "):rep(indent))

        if word and INC_INDENT[word] or line:find("{$") then indent = indent + 2 end

        if line:find("end[%l]+$") then indent = math.max(2, indent - 2) end
      else
        docs[i] = line:gsub("^([^%`%s])", " %1"):gsub("$", " ")
      end
    end

    if is_code and #unclosed == 0 then table.insert(docs, "```") end
    for i = #unclosed, 1, -1 do
      table.insert(docs, unclosed[i], "```")
      table.insert(docs, unclosed[i] + 1, "")
    end

    return details, docs
  end,
  typst = function(details, docs)
    local pattern = "%((.*)%) => (%w+)"
    local new_docs = nil

    details = vim.split(details --[[@as string]], "\n", { trimempty = true })
    docs = vim.split(docs --[[@as string]], "\n", { trimempty = true })

    if #details > 0 then
      local args, item = details[1]:match(pattern)
      new_docs = {}

      if args and item then
        table.insert(new_docs, "```typst")
        table.insert(new_docs, ("#let %s("):format(item))

        local args_list = vim.split(args, ", ", { trimempty = true })
        for _, arg in ipairs(args_list) do
          if #arg > 80 then
            local arg_split = vim.split(arg, " | ", { trimempty = true })
            local first_arg = arg:match("(%w+):")

            table.insert(new_docs, "  " .. arg_split[1])
            for i = 2, #arg_split do
              table.insert(new_docs, ("  %s| %s"):format((" "):rep(#first_arg), arg_split[i]))
            end
            new_docs[#new_docs] = new_docs[#new_docs] .. ","
          else
            table.insert(new_docs, "  " .. arg .. ",")
          end
        end

        table.insert(new_docs, ");")
        table.insert(new_docs, "```")

        details = new_docs
      end
    end
    return details, docs
  end,
  default = function(details, docs)
    details = vim.split(details --[[@as string]], "\n", { trimempty = true })
    docs = vim.split(docs --[[@as string]], "\n", { trimempty = true })

    if #details > 0 then
      local buf = vim.api.nvim_get_current_buf()
      table.insert(details, 1, ("```%s"):format(vim.bo[buf].ft or ""))
      table.insert(details, "```")

      if #docs > 0 and docs[1] ~= "---" then table.insert(docs, 1, "---") end
    end
    return details, docs
  end,
}

---@module "blink.cmp"
---@param opts blink.cmp.CompletionDocumentationDrawOpts
---@return string[]
function M.parse(opts)
  -- Modified from: https://github.com/OXY2DEV/nvim/blob/main/lua/plugins/lsp.lua#L168
  local ft = vim.bo.filetype

  local docs, details
  if opts.item then
    docs = opts.item.documentation and opts.item.documentation.value or ""
    details = opts.item.detail and opts.item.detail or ""
  end

  local parser = lang_parse[ft] or lang_parse.default
  details, docs = parser(details, docs)

  return vim.list_extend(details, docs)
end

return M
