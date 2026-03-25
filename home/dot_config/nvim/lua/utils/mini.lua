---@class Utils.mini
---@field ai    Utils.mini.ai    -- Text-objects for Mini AI
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

    if first_nonblank == 0 or last_nonblank == 0 then return { from = { line = start_line, col = 1 } } end

    start_line = first_nonblank
    end_line = last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

---Register all text-objects with which-key
---@param opts table WhichKey options
ai.whichkey = function(opts)
  ---@type { [1]:string, desc?: string, icon?: string }[]
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

M = {
  ai = ai,
}

return M
