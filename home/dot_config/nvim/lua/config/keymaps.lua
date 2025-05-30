local map = vim.keymap.set
local unmap = vim.keymap.del

-- stylua: ignore start

-- ╭─────────────────────────────────────────────────────────╮
-- │                         Editing                         │
-- ╰─────────────────────────────────────────────────────────╯

-- <C-s> to save
map({ "n", "i", "v", "s" }, "<C-s>",   "<ESC><CMD>w<CR>",  { desc = "Save changes" })
map({ "n", "i", "v", "s" }, "<C-S-s>", "<ESC><CMD>wa<CR>", { desc = "Save all changes" })

-- Quit
map("n", "<leader>Q",  "<CMD>qa<CR>", { desc = "Quit all" })
map("n", "<leader>qq", "<CMD>qa<CR>", { desc = "Quit all" })

-- Better up/down
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Natural Scrolling
map({ "n", "i", "v" }, "<ScrollWheelLeft>",  "<ScrollWheelRight>", { desc = "which_key_ignore" })
map({ "n", "i", "v" }, "<ScrollWheelRight>", "<ScrollWheelLeft>",  { desc = "which_key_ignore" })

-- Use gl and gl to go to the beginning and end of the line
map({ "n", "x" }, "gh", "^", { desc = "Start of line (non ws)" })
map({ "n", "x" }, "gl", "$", { desc = "End of line" })

-- Use <C-BS> to delete a word in insert mode
-- NOTE: requires kitty keyboard protocol
map({ "i", "c", "t" }, "<C-BS>", "<C-w>")
map({ "i", "c", "t" }, "<C-w>",  "<NOP>") -- disable default behavior, rewiring my brain

-- Delete selection with <BS> instead of entering normal mode
map("s", "<BS>", '<C-g>"_c', { desc = "Delete selection in insert mode" })

-- Add new line without entering insert mode
---@param dir "down" | "up"
local function add_line(dir)
  local ft = vim.bo.filetype
  local buftype = vim.bo.buftype

  -- In Vim command mode, execute the command with enter
  if ft == "vim" and buftype == "nofile" then
    local CR = Snacks.util.keycode("<CR>")
    vim.fn.feedkeys(CR, "n")
  end

  local cmd = dir == "down" and "] %sj" or "[ %sk"
  local count = vim.v.count1

  vim.fn.feedkeys(cmd:format(count))
end

map("n", "<S-CR>", function() add_line("up") end )
map("n", "<CR>",   function() add_line("down") end )

-- stylua: ignore end

-- Save position on yank
map({ "n", "x" }, "y", function()
  Utils.save_cursor_pos()
  return "y"
end, { expr = true, desc = "Yank" })
map("n", "Y", function()
  Utils.save_cursor_pos()
  return "yg_" -- yank without trailing newline
end, { expr = true, desc = "Yank until the end" })

-- Preserve cursor when commenting
local function comment()
  Utils.save_cursor_pos()
  local mode = vim.fn.mode()

  if mode == "n" or mode == "i" then
    vim.cmd.norm("gcc")
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd.norm("gc")
  end

  Utils.restore_cursor()
end

-- stylua: ignore start

map({ "n", "v" }, "<leader>/", comment, { desc = "Comment / Uncomment" })
map("i",          "<C-/>",     comment, { desc = "Comment / Uncomment" })

-- stylua: ignore end

-- Emacs paste behavior
---@param key "p" | "P"
local function paste(key)
  local count = vim.v.count1
  local reg_type = vim.fn.getregtype('"')
  local opts = nil

  if vim.fn.getreg('"') == "" then return end

  if reg_type == "V" then Utils.save_cursor_pos() end

  if key == "p" then opts = { row = 1 } end

  vim.cmd("normal! " .. count .. key)
  Utils.restore_cursor(opts)
end

-- stylua: ignore start

map("n", "p", function() paste("p") end, { noremap = true, silent = true, desc = "Paste (After)" })
map("n", "P", function() paste("P") end, { noremap = true, silent = true, desc = "Paste (Before)" })
map("x", "p", function() paste("P") end, { noremap = true, silent = true, desc = "Paste without yanking" })
map("x", "P", function() paste("p") end, { noremap = true, silent = true, desc = "Paste with yank" })

-- stylua: ignore end

-- Smart delete
---@param key string
---@param mode string
local function smart_delete(key, mode)
  if mode == "n" then
    local line = vim.api.nvim_get_current_line()
    return (line:match("^%s*$") and '"_' or "") .. key
  elseif mode == "v" then
    local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
    local all_space = true
    for _, line in ipairs(lines) do
      if not line:match("^%s*$") then
        all_space = false
        break
      end
    end
    return (all_space and '"_' or "") .. key
  end
end

local keys = {
  { "d", desc = "Delete" },
  { "dd", mode = "n", desc = "which_key_ignore" },
  { "c", desc = "Change" },
  { "C", desc = "which_key_ignore" },
  { "x", desc = "which_key_ignore" },
  { "X", desc = "which_key_ignore" },
}

for _, key_opts in pairs(keys) do
  local mode = { "n", "v" }
  mode = { key_opts.mode } or mode

  local opts = { expr = true }
  if key_opts.desc then opts.desc = key_opts.desc end

  local key = key_opts[1]
  for _, m in ipairs(mode) do
    map(m, key, function() return smart_delete(key, m) end, opts)
  end
end

-- ╭─────────────────────────────────────────────────────────╮
-- │                        Utilities                        │
-- ╰─────────────────────────────────────────────────────────╯

-- HACK: update heirline mode immediately after pressing the visual mode keys
-- While the autocommand solution (nvim/lua/config/autocmds.lua) works to update the statusline during
-- O-PENDING mode, it doesn't update the statusline correctly on mode V and <C-v> because which-key
-- put a defer to those mode. As a workaround, we surpress the which-key event by executing the mode
-- change directly. We then call which-key to show the menu after a delay so the statusline can be
-- redrawn before the event is blocked.

local mode_keys = { "v", "V", "\22" }
for _, key in ipairs(mode_keys) do
  map("n", key, function()
    local defer = key == "V" or key == "\22"
    vim.cmd("normal! " .. key)
    vim.defer_fn(function() require("which-key").show({ defer = defer }) end, 1)
  end)
end

-- stylua: ignore start
-- Unmap default gr
if vim.fn.maparg("grr", "n") then
  unmap("n", "grn")
  unmap("n", "gra")
  unmap("n", "grr")
  unmap("n", "gri")
end

-- Removed functionality
map({ "n", "x" }, "s", "<NOP>", { silent = true })

-- Disable Arrow Keys
map({ "n", "v" }, "<Up>",    "<NOP>")
map({ "n", "v" }, "<Down>",  "<NOP>")
map({ "n", "v" }, "<Left>",  "<NOP>")
map({ "n", "v" }, "<Right>", "<NOP>")

-- Center cursor when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Clear search and stop snippet
map({ "n", "i", "s" }, "<ESC>", function()
  local ls = Utils.lazy_require("luasnip")
  if ls.expand_or_jumpable() then ls.unlink_current() end

  vim.cmd("noh")
  return "<ESC>"
end, { expr = true, desc = "Escape, clear hlsearch, and stop snippet session" })

-- Increment / Decrement
map({ "n", "x" }, "+",  "<C-a>",  { desc = "Increment number" })
map({ "n", "x" }, "-",  "<C-x>",  { desc = "Decrement number" })
map("x",          "g+", "g<C-a>", { desc = "Increment number" })
map("x",          "g-", "g<C-x>", { desc = "Decrement number" })

-- Select all text
map({ "n", "i", "v" }, "<C-a>", "<ESC>ggVG", { desc = "Select all" })

-- Search inside selection
map("x", "/", "<ESC>/\\%V", { desc = "Search inside selection" })
map("x", "?", "<ESC>?\\%V", { desc = "Search inside selection" })

-- Redo with U
map("n", "U", "<C-r>", { desc = "Redo" })

-- Saner behavior of n and N
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]",      { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]",      { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]",      { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]",      { expr = true, desc = "Prev search result" })

-- stylua: ignore end

-- Location and Quickfix List
map("n", "<leader>xl", function()
  local success, err =
    pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)

  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Location List" })

map("n", "<leader>xq", function()
  local success, err =
    pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)

  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Quickfix List" })

-- stylua: ignore start

-- Undo Breakpoints
map("i", ",", ",<C-g>u", { desc = "Undo breakpoint" })
map("i", ".", ".<C-g>u", { desc = "Undo breakpoint" })
map("i", ";", ";<C-g>u", { desc = "Undo breakpoint" })

-- Highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- Code Format
map({ "n", "v" }, "<leader>cf", function() Utils.format.format({ force = true }) end, { desc = "[C]ode: [F]ormat" })

-- ╭─────────────────────────────────────────────────────────╮
-- │                 Windows, Split, Buffers                 │
-- ╰─────────────────────────────────────────────────────────╯

-- Buffers
map("n", "<leader>bd", function() Snacks.bufdelete() end,       { desc = "Delete Buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffer" })
map("n", "<leader>bD", "<CMD>:bd<CR>",                          { desc = "Delete Buffer and Window" })

-- Windows
map("n", "<leader>|",  "<C-w>v", { remap = true, desc = "Split Window Right [|]" })
map("n", "<leader>_",  "<C-w>s", { remap = true, desc = "Split Window Below [_]" })
map("n", "<leader>wd", "<C-w>c", { remap = true, desc = "Delete Window" })

-- Resize
map("n", "<C-Up>",    "<CMD>resize +2<CR>",          { desc = "Increase Window Height" })
map("n", "<C-Down>",  "<CMD>resize -2<CR>",          { desc = "Decrease Window Height" })
map("n", "<C-Left>",  "<CMD>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<CMD>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Navigate Window
map("n", "<C-h>", "<C-w>h", { remap = true, desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { remap = true, desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { remap = true, desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { remap = true, desc = "Go to Right Window" })

-- ╭─────────────────────────────────────────────────────────╮
-- │                           Git                           │
-- ╰─────────────────────────────────────────────────────────╯

map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function()
  ---@diagnostic disable-next-line: missing-fields
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })

-- stylua: ignore end
