return {
  condition = function() return vim.fn.reg_recording() ~= "" end,
  update = { "RecordingEnter", "RecordingLeave" },
  {
    condition = function() return vim.o.showtabline == 2 end,
    hl = { fg = "#d34e31" },
    { provider = " " },
    {
      provider = function() return (" Rec @%s"):format(vim.fn.reg_recording()) end,
      hl = { fg = "text", bg = "#d34e31", bold = true },
    },
    { provider = " " },
  },
  {
    condition = function() return vim.o.showtabline ~= 2 end,
    {
      provider = function() return ("  Rec @%s "):format(vim.fn.reg_recording()) end,
      hl = { fg = "peach" },
    },
  },
}
