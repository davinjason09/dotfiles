---@param dir "h"|"j"|"k"|"l"
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    if self:is_floating() then
      return vim.schedule(function() self:hide() end)
    end

    return vim.schedule(function() vim.cmd.wincmd(dir) end)
  end
end

return {
  "snacks.nvim",
  opts = {
    ---@type snacks.terminal.Opts
    terminal = {
      win = {
        style = "terminal",
        border = "rounded",
        position = "float",
        fixbuf = true,
        wo = {
          winbar = "",
          winhighlight = "Normal:SnacksTerminalNormal,FloatBorder:SnacksTerminalBorder",
        },
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          ["<C-`>"] = { "toggle", mode = "t" },
        },
      },
    },
  },
}
