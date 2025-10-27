-- stylua: ignore start
-- ╾╼ Leader Key ╾────────────────────────────────────────────────────╼
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- ╾╼ General ╾───────────────────────────────────────────────────────╼
vim.o.backup         = false       -- Don't store backup
vim.o.confirm        = true        -- Ask for confirmation before overwriting files
vim.o.laststatus     = 3           -- Always show status line
vim.o.switchbuf      = "usetab"    -- Use already opened buffers when switching
vim.o.writebackup    = false       -- Don't store backup files
vim.o.timeoutlen     = 300         -- Time to wait for mapped sequence to complete
vim.o.undofile       = true        -- Enable persistent undo
vim.o.undolevels     = 10000       -- Number of undo levels to keep
vim.o.updatetime     = 250         -- Time to wait before writing swap file and triggering CursorHold

vim.o.shada = "'100,<50,s10,:1000,/100,@100,h" -- Limit what is stored in ShaDa file
vim.o.shell = "/usr/bin/nu"

vim.g.markdown_recommended_style = 0 -- Don't use recommended style for markdown
vim.o.sessionoptions = table.concat( -- Options to save in session files
  { "buffers", "curdir", "folds", "globals", "help", "skiprtp", "tabpages", "winsize" }, ","
)

-- ╾╼ UI ╾────────────────────────────────────────────────────────────╼
vim.o.breakindent    = true        -- Indent wrapped lines to match the line start
vim.o.cmdheight      = 0           -- Height of command line
vim.o.conceallevel   = 2           -- Hide text until it is needed 
vim.o.cursorline     = true        -- Highlight the line with the cursor
vim.o.cursorlineopt  = "both"      -- Highlight the line with the cursor
vim.o.linebreak      = true        -- Wrap long lines
vim.o.number         = true        -- Show line numbers
vim.o.relativenumber = true        -- Show relative line numbers
vim.o.ruler          = false       -- Don't show cursor position
vim.o.shortmess      = 'FOWaco'    -- Disable certain messages from |ins-completion-menu|
vim.o.showmode       = false       -- Don't show mode in command line
vim.o.signcolumn     = 'yes'       -- Always show signcolumn or it would frequently shift
vim.o.smoothscroll   = true        -- Smooth scrolling
vim.o.splitbelow     = true        -- Horizontal splits will be below
vim.o.splitright     = true        -- Vertical splits will be to the right
vim.o.splitkeep      = "screen"    -- Keep the text on the same screen line 
vim.o.winminwidth    = 5           -- Minimum window width
vim.o.wrap           = false       -- Display long lines as just one line

vim.o.fillchars = table.concat(    -- Special UI symbols
  { "diff:/", "eob: ", "fold: ", "foldsep: ", "foldopen:", "foldclose:" }, ","
)
vim.o.listchars = table.concat(    -- Special text symbols
  { "eol:↩", "extends:…", "nbsp:␣", "precedes:…", "tab:»·", "trail:·" }, ","
)
vim.o.breakindentopt = "list:-1"   -- Add padding for list when `wrap` is enabled
vim.o.cursorlineopt  = "both"      -- Highlight text line and number where the cursor is
vim.o.termguicolors  = true        -- Enable 24-bit RGB colors in the TUI
vim.o.winborder      = "none"      -- Use no border for windows (at least until all plugins are updated to 0.11)

vim.g.health         = { style = "float" }  -- Use floating window for :checkhealth
vim.o.guicursor      = "n-v-sm:block,i-c-ci-ve-t:ver25,r-cr-o:hor20"    -- Change terminal and command mode cursor to bar

-- ╾╼ Editing ╾───────────────────────────────────────────────────────╼
vim.o.autoindent    = true         -- Use auto indent
vim.o.expandtab     = true         -- Convert tabs to spaces
vim.o.formatoptions = "rqnl1j"     -- Improve comment editing
vim.o.ignorecase    = true         -- Ignore case when searching
vim.o.incsearch     = true         -- Show search matches as you type
vim.o.shiftwidth    = 2            -- Number of spaces for indentation
vim.o.shiftround    = true         -- Round indent to multiple of 'shiftwidth'
vim.o.softtabstop   = 2            -- Number of spaces for a tab when editing
vim.o.smartcase     = true         -- Don't ignore case when searching with uppercase letters
vim.o.smartindent   = true         -- Make indenting smarter
vim.o.tabstop       = 2            -- Number of spaces for a tab
vim.o.whichwrap     = "b,s,[,]"    -- Allow moving to previous/next line with <Left>/<Right> in insert mode
vim.o.virtualedit   = "block"      -- Allow going past the end of line in V-BLOCK mode

vim.o.grepprg       = "rg --vimgrep"                  -- Use ripgrep for searching
vim.o.grepformat    = "%f:%l:%c:%m"                   -- Format for grep results
vim.o.iskeyword     = '@,48-57,_,192-255,-'           -- Treat dash separated words as a word text object
vim.o.scrolloff     = math.floor(0.3 * vim.o.lines)   -- Keep 30% of the screen height above and below the cursor

-- Define pattern for a start of 'numbered' list. This is responsible for correct formatting of lists when using `gw`. This basically reads as 'at
-- least one special character (digit, -, +, *) possibly followed some punctuation (. or `)`) followed by at least one space is a start of list
-- item'
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]
vim.o.formatexpr    = "v:lua.Utils.format.formatexpr()" -- Custom format expression
vim.g.autoformat    = true

-- ╾╼ Folds ╾─────────────────────────────────────────────────────────╼
vim.g.markdown_folding = 1         -- Use folding by heading in markdown files
vim.o.foldcolumn = "auto"          -- Fold column width
vim.o.foldlevel  = 99              -- Display all folds
vim.o.foldmethod = "indent"        -- Use indent for folding
vim.o.foldtext   = ""              -- Use underlying text with its highlighting
vim.o.foldenable = false           -- Disable folding by default

-- ╾╼ Spelling ╾──────────────────────────────────────────────────────╼
vim.o.spelllang    = "en"          -- Default spelling dictionary
vim.o.spelloptions = "camel"       -- Treat camel case words as separate words

-- ╾╼ Clipboard ╾─────────────────────────────────────────────────────╼
vim.o.clipboard = "unnamedplus" -- Use system clipboard for all operations
vim.g.clipboard = {             -- WSL clipboard (win32yank) 
  name = "wsl-clipboard",
  copy = {
    ["+"] = { "wslyank", "-i", "--crlf" },
    ["*"] = { "wslyank", "-i", "--crlf" },
  },
  paste = {
    ["+"] = { "wslyank", "-o", "--lf" },
    ["*"] = { "wslyank", "-o", "--lf" },
  },
  cache_enabled = 0,
}
