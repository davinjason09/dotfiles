---@class Defaults
local M = {}

---Default colorscheme palette
---@type CtpColors<string> | CtpColor
M.palette = {}

---Fill the palette with the default colorscheme
---@param palette CtpColors<string> | CtpColor
function M.filling_palette(palette) M.palette = palette end

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

-- stylua: ignore end

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
