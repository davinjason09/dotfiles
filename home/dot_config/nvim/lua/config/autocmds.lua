local function augroup(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

-- HACK: update heirline statusline that relies on ModeChanged
-- Based on https://github.com/rebelot/heirline.nvim/issues/219 it seems that which-key is blocking the
-- ModeChanged event. As a workaround, we execute a separate User event to force heirline to update the
-- statusline.

vim.api.nvim_create_autocmd("ModeChanged", {
  group = augroup("ForceRedrawStatusline"),
  pattern = "*:*",
  callback = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "ForceRedraw", modeline = false })
  end,
  desc = "Workaround for heirline statusline redraw due to which-key blocking the ModeChanged event",
})
