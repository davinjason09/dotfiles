local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local npairs = require("nvim-autopairs")

local function curly_semicolon(line)
  local keywords = { "struct", "class", "enum", "union" }
  for _, keyword in ipairs(keywords) do
    if line:match("^%s*" .. keyword .. ".*") then return true end
  end
end

npairs.get_rules("{")[1].not_filetypes = { "cpp", "c" }

npairs.add_rules({
  Rule("{", "};", "cpp")
    :with_pair(function(o) return curly_semicolon(o.line) end)
    :with_del(cond.done())
    :with_move(cond.done()),
  Rule("{", "}", "cpp")
    :with_pair(function(o) return not curly_semicolon(o.line) end)
    :with_del(cond.done())
    :with_move(cond.done()),
})
