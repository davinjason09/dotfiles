---@class Utils.mini
---@field ai    Utils.mini.ai    -- Text-objects for Mini AI
---@field pairs Utils.mini.pairs -- Pairs functionality for Mini Pairs
local M = {}

---@class Utils.mini.ai
local ai = {}

---Get current buffer text-objects
---@param ai_type string The text-object type, either `i` or `a`
ai.buffer = function(ai_type)
  local start_line = 1
  local end_line = vim.fn.line("$")

  if ai_type == "i" then
    local first_nonblank = vim.fn.nextnonblank(start_line)
    local last_nonblank = vim.fn.prevnonblank(end_line)

    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end

    start_line = first_nonblank
    end_line = last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

---Register all text-objects with which-key
---@param opts table WhichKey options
ai.whichkey = function(opts)
  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "U", desc = "use/call without dot" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "`", desc = "` string" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "c", desc = "class" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "f", desc = "function" },
    { "g", desc = "entire file" },
    { "i", desc = "indent" },
    { "o", desc = "block, conditional, loop" },
    { "q", desc = "quote `\"'" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
    { "{", desc = "{} block" },
    { "}", desc = "{} with ws" },
  }

  ---@type wk.Spec[]
  local ret = { mode = { "o", "x" } }
  ---@type table<string, string>
  local mappings = vim.tbl_extend("force", {}, {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
  }, opts.mappings or {})

  mappings.goto_left = nil
  mappings.goto_right = nil

  for name, prefix in pairs(mappings) do
    name = name:gsub("^around_", ""):gsub("^inside_", "")
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      local icon = obj.icon or " "

      if prefix:sub(1, 1) == "i" then desc = desc:gsub(" with ws ", "") end

      ret[#ret + 1] = { prefix .. obj[1], desc = desc, icon = icon }
    end
  end

  require("which-key").add(ret, { notify = false })
end

---@class Utils.mini.pairs
local pairs = {}

local code_blocks_ft = { "markdown", "typst" }

---Functionality for markdown, treesitter and unbalanced pairs
---@alias PairsOpts { skip_next: string, skip_ts: string[], skip_unbalanced: boolean, code_blocks: boolean } Mini.pairs options
---@param opts PairsOpts
pairs.setup = function(opts)
  local MiniPairs = require("mini.pairs")
  MiniPairs.setup(opts)

  local open = MiniPairs.open
  ---@diagnostic disable-next-line: duplicate-set-field
  MiniPairs.open = function(pair, neigh_pattern)
    if vim.fn.getcmdline() ~= "" then return open(pair, neigh_pattern) end

    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])

    if
      opts.code_blocks
      and o == "`"
      and vim.tbl_contains(code_blocks_ft, vim.bo.filetype)
      and before:match("^%s*``")
    then
      local UP = vim.api.nvim_replace_termcodes("<Up>", true, true, true)
      return "`\n```" .. UP
    end

    if opts.skip_next and next ~= "" and next:match(opts.skip_next) then return o end

    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures =
        pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then return o end
      end
    end

    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
      if count_close > count_open then return o end
    end
    return open(pair, neigh_pattern)
  end
end

M = {
  ai = ai,
  pairs = pairs,
}

return M
