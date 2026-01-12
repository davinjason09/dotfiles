---@class Defaults
local M = {}

---Default colorscheme palette

---@type CtpColors<string>|{}
M.palette = {}

---Fill the palette with the default colorscheme
---@param palette CtpColors<string>
function M.filling_palette(palette) M.palette = palette end

M.bigfile = {
  size = 1024 * 1024 * 1.5,
  line_length = 1000,
}

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

M.special_ft_icons = {
  yazi    = { "󰇥", "MiniIconsYellow" },
  vim     = { "", "MiniIconsGreen" },
  wezterm = { "", "MiniIconsPurple" }
}

-- stylua: ignore end

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
  max_width = math.max(math.floor(vim.o.columns * 0.6), 100),
  max_height = math.min(math.floor(vim.o.lines * 0.4), 20),
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
  "help",
  "lazy",
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
    { icon = " ", pattern = "c%]?olor", color = "azure" },
    { icon = " ", pattern = "c%]?ommand", color = "orange" },
    { icon = " ", pattern = "c%]?onfig", color = "red" },
    { icon = "󱖫 ", pattern = "diagnostics", color = "green" },
    { icon = " ", pattern = "%f[%a/%p]%[?f%]?ile", color = "cyan" },
    { icon = "󱩾 ", pattern = "g%]?rep", color = "green" },
    { icon = " ", pattern = "h%]?ighlight", color = "purple" },
    { icon = " ", pattern = "i%]?con", color = "yellow" },
    { icon = "󰜎 ", pattern = "j%]?ump", color = "orange" },
    { icon = " ", pattern = "k%]?eymap", color = "yellow" },
    { icon = " ", pattern = "%f[%a]%[?l%]?ine", color = "cyan" },
    { icon = "󱖫 ", pattern = "l%]?ocation list", color = "green" },
    { icon = "󰸕 ", pattern = "m%]?ark%f[%a]", color = "orange" },
    { icon = " ", pattern = "p%]?roject", color = "cyan" },
    { icon = "󱖫 ", pattern = "q%]?uickfix", color = "green" },
    { icon = " ", pattern = "r%]?ecent", color = "cyan" },
    { icon = "󰑓 ", pattern = "r%]?eload", color = "purple" },
    { icon = " ", pattern = "r%]?egister", color = "orange" },
    { icon = " ", pattern = "r%]?eplace", color = "red" },
    { icon = " ", pattern = "r%]?esume", color = "green" },
    { icon = " ", pattern = "t%]?erminal", color = "red" },
    { icon = " ", pattern = "t%]?odo", color = "purple" },
    { icon = "󰙅 ", pattern = "u%]?ndo", color = "orange" },
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
    { icon = " ", pattern = "spell", color = "red" },
    { icon = "󱅫 ", pattern = "notif", color = "blue" },
    { icon = " ", pattern = "inspect", color = "red" },
    { icon = " ", pattern = "align", color = "cyan" },
    { icon = " ", pattern = "add", color = "green" },
    { icon = " ", pattern = "create", color = "green" },
    { icon = " ", pattern = "delete", color = "red" },
    { icon = " ", pattern = "close", color = "red" },
    { icon = "󰮫 ", pattern = "open", color = "green" },
    { icon = "󱗋 ", pattern = "increment", color = "yellow" },
    { icon = "󱗋 ", pattern = "more", color = "yellow" },
    { icon = "󱁒 ", pattern = "decrement", color = "yellow" },
    { icon = "󱁒 ", pattern = "less", color = "yellow" },
    { icon = "󱅅 ", pattern = "update", color = "yellow" },
    { icon = "󱅅 ", pattern = "change", color = "yellow" },
    { icon = " ", pattern = "first", color = "blue" },
    { icon = " ", pattern = "prev", color = "blue" },
    { icon = " ", pattern = "next", color = "blue" },
    { icon = " ", pattern = "last", color = "blue" },
    { icon = " ", pattern = "up$", color = "blue" },
    { icon = " ", pattern = "%f[%a]down", color = "blue" },
    { icon = " ", pattern = "left", color = "blue" },
    { icon = " ", pattern = "right", color = "blue" },
    { icon = "󰑎 ", pattern = "redo", color = "green" },
    { icon = "󰅩 ", pattern = "%{%}", color = "yellow" },
    { icon = "󰬶 ", pattern = "uppercase", color = "orange" },
    { icon = "󰬵 ", pattern = "lowercase", color = "orange" },
    { icon = " ", pattern = "run", color = "red" },
  },
}

M.formatter_rules = {
  biome = { "biome.json", "biome.jsonc" },
  ["clang-format"] = { ".clang-format", "clang-format" },
  oxfmt = { ".oxfmtrc.json", ".oxfmtrc.jsonc" },
  stylua = { ".stylua.toml", "stylua.toml" },
}

M.noice_cmdline_format = function()
  ---Add powerline symbols to the title of popups
  ---@alias title_opts { msg: string, views?: string, kind?: string }
  ---@param opts title_opts
  local title = function(opts)
    opts.views = opts.views or "cmdline_popup" --[[@as string]]

    local powerline_hl = ""
    if opts.views == "confirm" then
      powerline_hl = "NoiceConfirmBorder"
    elseif opts.kind then
      powerline_hl = "NoiceCmdlinePopupBorder" .. opts.kind:sub(1, 1):upper() .. opts.kind:sub(2)
    end

    return {
      { "", powerline_hl },
      { opts.msg },
      { "", powerline_hl },
    }
  end

  local nvim_version = ("  v%s "):format(Utils.nvim_version())
  local lua_version = ("  %s "):format(_VERSION)

  return {
    calculator = {
      icon = "=",
      lang = "vim",
      kind = "calculator",
      pattern = "^=",
      title = title({ msg = "  Calculator ", kind = "calculator" }),
    },
    cmdline = {
      icon = "❯",
      lang = "vim",
      kind = "cmdline",
      pattern = "^:",
      icon_hl_group = "MiniIconsGreen",
      title = title({ msg = nvim_version, kind = "cmdline" }),
    },
    filter = {
      icon = "",
      lang = "bash",
      kind = "filter",
      pattern = "^:%s*!",
      icon_hl_group = "MiniIconsGreen",
      title = title({ msg = "  Shell ", kind = "filter" }),
    },
    help = {
      icon = "",
      lang = "text",
      kind = "help",
      pattern = "^:%s*[hH]e?l?p?%s+",
      title = title({ msg = "  Help ", kind = "help" }),
    },
    lua = {
      icon = "",
      lang = "lua",
      kind = "lua",
      pattern = "^:%s*lua%s+",
      icon_hl_group = "MiniIconsAzure",
      title = title({ msg = lua_version, kind = "lua" }),
    },
    lua_eval = {
      icon = "",
      lang = "lua",
      kind = "cmdline",
      pattern = { "^:%s*lua%s*=%s*", "^:%s*=%s*" },
      title = title({ msg = nvim_version, kind = "cmdline" }),
    },
    search_down = { icon = "  ", lang = "regex", kind = "search", pattern = "^/" },
    search_up = { icon = "  ", lang = "regex", kind = "search", pattern = "^%?" },
    replace = {
      icon = "  Replace:",
      lang = "regex",
      kind = "search",
      pattern = { "^:%s*%%s?n?o?m?/", "^:'<,'>%s*s?n?m?/", "^:%d+,%d+%s*s?n?m?/" },
      view = "cmdline",
    },
    input = {
      icon = " ",
      lang = "text",
      kind = "input",
      view = "cmdline_popup",
      title = title({ msg = "  Input ", kind = "input" }),
    },
  }
end

return M
