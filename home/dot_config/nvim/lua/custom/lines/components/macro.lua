return {
  update = {
    "RecordingEnter",
    "RecordingLeave",
    callback = function() require("custom.lines.utils").redraw("all") end,
  },
  fallthrough = false,
  {
    condition = function() return vim.o.showtabline == 2 and vim.fn.reg_recording() ~= "" end,
    hl = { fg = "#d34e31" },
    { provider = " " },
    {
      provider = function() return (" Rec @%s"):format(vim.fn.reg_recording()) end,
      hl = { fg = "text", bg = "#d34e31", bold = true },
    },
    { provider = " " },
  },
  {
    condition = function() return vim.fn.reg_recording() ~= "" end,
    provider = function() return ("  Rec @%s "):format(vim.fn.reg_recording()) end,
    hl = { fg = "peach" },
  },
}
