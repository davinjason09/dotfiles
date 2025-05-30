local is_nofile = vim.bo.buftype == "nofile"

vim.opt_local.wrap = not is_nofile
vim.opt_local.linebreak = true
vim.opt_local.spell = not is_nofile

local Rule = require("nvim-autopairs.rule")
local npairs = require("nvim-autopairs")
local ts_conds = require("nvim-autopairs.ts-conds")

local not_inside_code_block = ts_conds.is_not_ts_node({
  "fenced_code_block",
  "indented_code_block",
  "code_span",
})

npairs.add_rules({
  Rule("```", "```", "markdown"),
  Rule("$", "$", "markdown"),
  Rule("*", "*", "markdown"),
  Rule("![", "]()", "markdown"):set_end_pair_length(1),
  -- italics
  Rule("_", "_", "markdown"):with_pair(not_inside_code_block),
  Rule("*", "*", "markdown"):with_pair(not_inside_code_block),
  -- bold
  Rule("__", "__", "markdown"):with_pair(not_inside_code_block),
  Rule("**", "**", "markdown"):with_pair(not_inside_code_block),
})
