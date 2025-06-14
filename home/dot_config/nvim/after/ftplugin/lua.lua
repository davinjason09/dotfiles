local Rule = require("nvim-autopairs.rule")
local npairs = require("nvim-autopairs")
local ts_conds = require("nvim-autopairs.ts-conds")

npairs.add_rules({
  Rule("{", "},", "lua"):with_pair(ts_conds.is_ts_node({ "field", "table_constructor" })),
  Rule("'", "',", "lua"):with_pair(ts_conds.is_ts_node({ "field", "table_constructor" })),
  Rule('"', '",', "lua"):with_pair(ts_conds.is_ts_node({ "field", "table_constructor" })),
  Rule("<", ">", "lua")
    :with_pair(ts_conds.is_ts_node({ "string", "string_content" }))
    :with_move(function(o) return o.char == ">" end),
})
