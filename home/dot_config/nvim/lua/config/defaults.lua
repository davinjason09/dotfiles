---@class Defaults
local M = {}

---Default colorscheme palette
---@type CtpColors<string> | CtpColor
M.palette = {}

---Fill the palette with the default colorscheme
---@param palette CtpColors<string> | CtpColor
function M.filling_palette(palette) M.palette = palette end

M.small_screen_threshold = 30

-- stylua: ignore start

-- Default icons
M.icons = {
  kind = {
    Array         = " ",
    Boolean       = "󰨙 ",
    Class         = " ",
    Color         = "󱓻 ",
    Control       = " ",
    Constant      = "󰏿 ",
    Constructor   = " ",
    Copilot       = " ",
    Enum          = " ",
    EnumMember    = " ",
    Event         = " ",
    Field         = " ",
    File          = " ",
    Folder        = " ",
    Function      = "󰡱 ",
    Interface     = " ",
    Key           = "󰌋 ",
    Keyword       = " ",
    Method        = " ",
    Module        = " ",
    Namespace     = "󰦮 ",
    Null          = "󰟢 ",
    Number        = "󰎠 ",
    Object        = " ",
    Operator      = " ",
    Package       = " ",
    Property      = " ",
    Reference     = " ",
    Snippet       = " ",
    String        = " ",
    Struct        = " ",
    Text          = "󰉿 ",
    TypeParameter = " ",
    Unit          = " ",
    Value         = "󰎠 ",
    Variable      = " ",
  },
  diagnostics = {
    ERROR = " ",
    HINT  = " ",
    INFO  = " ",
    WARN  = " ",
  },
  modes = {
    Normal   = "",
    Insert   = "",
    Visual   = "",
    Command  = "",
    Terminal = "",
    Select   = "󰒉",
    Replace  = "",
    More     = "󰇙",
    Confirm  = "",
    Shell    = "",
    Prompt   = "󰗧",
  },
}

-- lazy.nvim default icons
M.lazy_nvim_icons = {
  cmd        = "",
  config     = "",
  event      = "",
  ft         = "",
  import     = "",
  loaded     = "",
  not_loaded = "󰊠",
  plugin     = " ",
  runtime    = "",
  source     = "",
  start      = "",
  list       = { "●", "○", "", "" },
}

-- Mason default icons
M.mason_icons = {
  package_installed   = " ",
  package_pending     = " ",
  package_uninstalled = "󰊠 ",
}

-- stylua: ignore end

-- Default vim.diagnostic config
---@type vim.diagnostic.Opts
M.diagnostics = {
  signs = {
    -- stylua: ignore
    text = {
      [vim.diagnostic.severity.ERROR] = M.icons.diagnostics.ERROR,
      [vim.diagnostic.severity.WARN]  = M.icons.diagnostics.WARN,
      [vim.diagnostic.severity.INFO]  = M.icons.diagnostics.INFO,
      [vim.diagnostic.severity.HINT]  = M.icons.diagnostics.HINT,
    },
  },
  underline = true,
  update_in_insert = false,
  virtual_text = { prefix = "", spacing = 0 },
  virtual_lines = { current_line = true },
}

local border = {
  { "╭", "LSPHoverBorder" },
  { "─", "LSPHoverBorder" },
  { "╮", "LSPHoverBorder" },
  { "│", "LSPHoverBorder" },
  { "╯", "LSPHoverBorder" },
  { "─", "LSPHoverBorder" },
  { "╰", "LSPHoverBorder" },
  { "│", "LSPHoverBorder" },
}

---@type vim.lsp.util.open_floating_preview.Opts
M.hover_opts = {
  border = border,
  max_width = math.max(vim.o.columns * 0.6, 100),
  max_height = math.min(vim.o.lines * 0.4, 20),
}

-- Default LSP capabilities
---@type lsp.ClientCapabilities
M.capabilities = {
  textDocument = {
    foldingRange = {
      dynamicRegistration = true,
      lineFoldingOnly = true,
    },
  },
  workspace = {
    fileOperations = {
      didRename = true,
      willRename = true,
    },
  },
}

-- Excluded filetypes for scope indent
M.excluded_filetypes = {
  "",
  "grug-far",
  "grug-far-help",
  "grug-far-history",
  "help",
  "lazy",
  "lspinfo",
  "mason",
  "markdown",
  "neo-tree",
  "netrw",
  "nofile",
  "notify",
  "prompt",
  "qf",
  "snacks_picker_list",
  "snacks_picker_input",
  "snacks_picker_preview",
  "terminal",
  "toggleterm",
  "trouble",
  "tutor",
  "vim",
  "wk",
}

return M
