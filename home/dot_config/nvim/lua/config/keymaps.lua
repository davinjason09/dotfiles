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
map({ "i", "c", "t" }, "<C-S-BS>", "<C-u>")

-- Better movement in insert mode, especially around wrapped lines
map("i", "<Down>", function() vim.cmd("normal! gj") end)
map("i", "<Up>",   function() vim.cmd("normal! gk") end)

-- Better keymaps on select mode
map("s", "<BS>", '<C-g>"_c')
map("s", "<Left>", "<ESC>i")
map("s", "<Right>", "<C-g>o<ESC>a")

-- Don't include trailing whitespace on visual mode
map("x", "$", "g_", { silent = true })

-- Add new line without entering insert mode
-- NOTE: requires Neovim 0.11+ due to the new ]<space> and [<space> mappings
map("n", "<S-CR>", function() Utils.edit.add_line("up") end, { silent = true } )
map("n", "<CR>",   function() Utils.edit.add_line("down") end, { silent = true } )

-- stylua: ignore end

-- Save position on yank
map({ "n", "x" }, "y", function()
  if vim.fn.line("'c") == 0 then Utils.edit.save_cursor_pos() end
  return "y"
end, { expr = true, desc = "Yank" })
map("n", "Y", function()
  Utils.edit.save_cursor_pos()
  return "yg_" -- yank without trailing newline
end, { expr = true, desc = "Yank until the end" })

-- stylua: ignore start

-- Preserve cursor when commenting
map({ "n", "v" }, "<leader>/", Utils.edit.comment, { desc = "Comment / Uncomment" })
map("i",          "<C-/>",     Utils.edit.comment, { desc = "Comment / Uncomment" })

-- Emacs paste behavior
map("n", "p", function() Utils.edit.paste("p") end, { noremap = true, silent = true, desc = "Paste (After)" })
map("n", "P", function() Utils.edit.paste("P") end, { noremap = true, silent = true, desc = "Paste (Before)" })
map("x", "p", function() Utils.edit.paste("P") end, { noremap = true, silent = true, desc = "Paste without yanking" })
map("x", "P", function() Utils.edit.paste("p") end, { noremap = true, silent = true, desc = "Paste with yank" })

-- stylua: ignore end

-- Smart delete
local keys = {
  { "d", desc = "Delete" },
  { "dd", mode = "n" },
  { "c", desc = "Change" },
  { "C" },
  { "x" },
  { "X" },
}

for _, key_opts in pairs(keys) do
  local mode = { key_opts.mode } or { "n", "v" }

  local opts = { expr = true }
  if key_opts.desc then opts.desc = key_opts.desc or "which_key_ignore" end

  local key = key_opts[1]
  for _, m in ipairs(mode) do
    map(m, key, function() return Utils.edit.smart_delete(key, m) end, opts)
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

-- Unmap default gr
local function remove(mode, key)
  if vim.fn.maparg(key, mode[1] or mode) then unmap(mode, key) end
end

remove("n", "grn")
remove({ "n", "x" }, "gra")
remove("n", "grr")
remove("n", "gri")
remove("n", "grt")

-- stylua: ignore start
-- Removed functionality
map({ "n", "x" }, "s", "<NOP>", { silent = true })

-- Disable Arrow Keys
map({ "n", "x" }, "<Up>",    "<NOP>")
map({ "n", "x" }, "<Down>",  "<NOP>")
map({ "n", "x" }, "<Left>",  "<NOP>")
map({ "n", "x" }, "<Right>", "<NOP>")

-- Center cursor when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Clear search and stop snippet
map({ "n", "i", "v", "s" }, "<ESC>", function()
  local ls = Utils.lazy_require("luasnip")
  if ls.expand_or_jumpable() then ls.unlink_current() end

  vim.cmd("noh")
  Utils.edit.restore_cursor()
  return "<ESC>"
end, { expr = true, desc = "Escape, clear hlsearch, and stop snippet session" })

-- Increment / Decrement
map({ "n", "x" }, "+",  "<C-a>",  { desc = "Increment number" })
map({ "n", "x" }, "-",  "<C-x>",  { desc = "Decrement number" })
map("x",          "g+", "g<C-a>", { desc = "Increment number" })
map("x",          "g-", "g<C-x>", { desc = "Decrement number" })

-- Select all text
map({ "n", "i", "v" }, "<C-a>", "<ESC>mcggVG", { desc = "Select all" })

-- Search inside selection / when in insert mode
map("x", "/", "<ESC>/\\%V", { desc = "Search inside selection" })
map("x", "?", "<ESC>?\\%V", { desc = "Search inside selection" })
map("i", "<C-f>", "<C-o>/", { desc = "Search in insert mode" })

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

-- Location and Quickfix List
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)

  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Location List" })

map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)

  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Quickfix List" })

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

-- Execute current file
map("n", "<leader>dx", "<CMD>source %<CR>", { desc = "[D]ebug: E[X]ecute file" })

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
map("n", "<C-Left>",  "<CMD>vertical resize +2<CR>", { desc = "Increase Window Width" })
map("n", "<C-Right>", "<CMD>vertical resize -2<CR>", { desc = "Decrease Window Width" })

-- Navigate Window
map("n", "<C-h>", "<C-w>h", { remap = true, desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { remap = true, desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { remap = true, desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { remap = true, desc = "Go to Right Window" })

-- ╭─────────────────────────────────────────────────────────╮
-- │                        Terminal                         │
-- ╰─────────────────────────────────────────────────────────╯

local Terminal = Utils.lazy_require("custom.terminal")
map({ "n", "i", "x" }, "<C-`>", Terminal.toggle, { desc = "Toggle Terminal" })

-- ╭─────────────────────────────────────────────────────────╮
-- │                           Git                           │
-- ╰─────────────────────────────────────────────────────────╯

map("n", "<leader>gg", function() Terminal.open("lazygit") end, { desc = "[G]it: Lazy[G]it" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "[G]it: [B]rowse (open)" })
map({ "n", "x" }, "<leader>gY", function()
  ---@diagnostic disable-next-line: missing-fields
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "[G]it: Browse [Y]ank" })

-- stylua: ignore end
