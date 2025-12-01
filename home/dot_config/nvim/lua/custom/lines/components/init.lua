return {
  -- Statusline
  ViMode = require("custom.lines.components.mode"),
  Git = require("custom.lines.components.git"),
  FileName = require("custom.lines.components.filename"),
  Lazy = require("custom.lines.components.lazy"),
  AI = require("custom.lines.components.ai"),
  Lsp = require("custom.lines.components.lsp"),
  Ruler = require("custom.lines.components.ruler"),
  Clock = require("custom.lines.components.clock"),
  Terminal = require("custom.lines.components.terminal"),
  Special = require("custom.lines.components.special"),
  -- Tabline
  Macro = require("custom.lines.components.macro"),
  Buffer = require("custom.lines.components.buffer"),
  TabPage = require("custom.lines.components.tabpage"),
  Offset = require("custom.lines.components.offset"),
  Misc = require("custom.lines.components.misc"),
}
