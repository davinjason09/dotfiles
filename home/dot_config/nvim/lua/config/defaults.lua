---@class Defaults
local M = {}

---Default colorscheme palette
---@type CtpColors<string> | CtpColor
M.palette = {}

---Fill the palette with the default colorscheme
---@param palette CtpColors<string> | CtpColor
function M.filling_palette(palette) M.palette = palette end

M.small_screen_threshold = 45
M.max_lsp_log_size = 1024 * 1024 * 1.5 -- 1.5MB

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
  git = {
    commit    = "󰜘 ",
    staged    = "●",
    added     = "",
    deleted   = "",
    ignored   = "",
    modified  = "",
    renamed   = "",
    unmerged  = " ",
    untracked = "",
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

M.which_key_rules = {
  rules = {
    { pattern = "%f[%a]%[?g%]?it", cat = "filetype", name = "git" },
    { pattern = "lazy", cat = "filetype", name = "lazy" },

    { icon = " ", pattern = "profiler", color = "yellow" },
    { icon = " ", pattern = "toggle", color = "yellow" },
    { icon = "󱀢 ", pattern = "c%]?omment", color = "yellow" },
    { icon = "󰆏 ", pattern = "yank", color = "orange" },
    { icon = "󰅌 ", pattern = "paste", color = "orange" },
    { icon = "󱈅 ", pattern = "visual selection", color = "green" },
    { icon = "󰼢 ", pattern = "visual", color = "purple" },

    { icon = " ", pattern = "c%]?md", color = "orange" },
    { icon = " ", pattern = "c%]?olor", color = "azure" },
    { icon = " ", pattern = "c%]?ommand", color = "orange" },
    { icon = " ", pattern = "c%]?onfig", color = "red" },
    { icon = "󱖫 ", pattern = "diagnostics", color = "green" },
    { icon = " ", pattern = "%f[%a/%p]%[?f%]?ile", color = "cyan" },
    { icon = "󱩾 ", pattern = "g%]?rep", color = "green" },
    { icon = " ", pattern = "h%]?ighlight", color = "purple" },
    { icon = " ", pattern = "i%]?con", color = "yellow" },
    { icon = "󰜎 ", pattern = "j%]?ump", color = "orange" },
    { icon = " ", pattern = "k%]?eymap", color = "yellow" },
    { icon = " ", pattern = "%f[%a]%[?l%]?ine", color = "cyan" },
    { icon = "󱖫 ", pattern = "l%]?ocation list", color = "green" },
    { icon = "󰸕 ", pattern = "m%]?ark%f[%a]", color = "orange" },
    { icon = "󰪻 ", pattern = "p%]?roject", color = "cyan" },
    { icon = "󱖫 ", pattern = "q%]?uickfix", color = "green" },
    { icon = "󱋢 ", pattern = "r%]?ecent", color = "cyan" },
    { icon = " ", pattern = "r%]?egister", color = "orange" },
    { icon = " ", pattern = "r%]?eplace", color = "red" },
    { icon = "󱩾 ", pattern = "r%]?esume", color = "green" },
    { icon = " ", pattern = "t%]?erminal", color = "red" },
    { icon = " ", pattern = "t%]?odo", color = "purple" },
    { icon = "󰙅 ", pattern = "u%]?ndotree", color = "orange" },
    { icon = " ", pattern = "w%]?ord", color = "yellow" },

    { icon = " ", pattern = "b%]?uffer", color = "cyan" },
    { icon = "󰙅 ", pattern = "e%]?xplorer", color = "green" },
    { icon = "󰙵 ", pattern = "%f[%a]ui", color = "cyan" },
    { icon = " ", pattern = "%f[%a]new tab", color = "blue" },
    { icon = " ", pattern = "%f[%a]new%f[%a]", color = "cyan" },

    { icon = "󰘥 ", pattern = "%f[%a]h%]?elp", color = "green" },
    { icon = "󰘥 ", pattern = "%f[%a]m%]?an", color = "green" },
    { icon = "󰘥 ", pattern = "%f[%a]keywordprg", color = "green" },
    { icon = " ", pattern = "f%]?ind", color = "green" },
    { icon = " ", pattern = "s%]?earch", color = "green" },
    { icon = " ", pattern = "f%]?ormat", color = "cyan" },

    { icon = " ", plugin = "persistence.nvim", color = "azure" },

    { icon = " ", pattern = "window", color = "blue" },
    { icon = "󱅫 ", pattern = "notif", color = "blue" },
    { icon = " ", pattern = "inspect", color = "red" },
    { icon = " ", pattern = "align", color = "cyan" },
    { icon = " ", pattern = "add", color = "green" },
    { icon = " ", pattern = "delete", color = "red" },
    { icon = "󱅅 ", pattern = "update", color = "yellow" },
    { icon = "󱅅 ", pattern = "change", color = "yellow" },
    { icon = " ", pattern = "last", color = "blue" },
    { icon = " ", pattern = "prev", color = "blue" },
    { icon = " ", pattern = "next", color = "blue" },
    { icon = " ", pattern = "up$", color = "blue" },
    { icon = " ", pattern = "%f[%a]down", color = "blue" },
    { icon = " ", pattern = "left", color = "blue" },
    { icon = " ", pattern = "right", color = "blue" },
  },
}

M.formatter_rules = {
  ["clang-format"] = { ".clang-format", ".clangd", "clang-format" },
  stylua = { ".stylua.toml", "stylua.toml" },
}

return M
