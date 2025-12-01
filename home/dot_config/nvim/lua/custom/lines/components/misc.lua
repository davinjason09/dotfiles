local M = {}

M.Tabline = {
  Left = {
    {
      provider = "  ",
      hl = { fg = "base", bg = "lavender" },
    },
    {
      provider = " ",
      hl = { fg = "lavender" },
    },
  },
  Right = {
    {
      provider = " ",
      hl = { fg = "lavender" },
    },
    {
      provider = " 󰮯  ",
      hl = { fg = "base", bg = "lavender" },
    },
  },
}

return M
