local function augroup(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("HighlightYank"),
  callback = function()
    vim.hl.on_yank()
    Utils.restore_cursor()
  end,
  desc = "Highlight on yank and preserve cursor position",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("FormatOptions"),
  callback = function()
    -- Don't auto-wrap comments and don't insert comment leader after hitting 'o'
    -- If don't do this on `FileType`, this keeps reappearing due to being set in
    -- filetype plugins.
    vim.opt_local.formatoptions:remove({ "o", "c" })
  end,
  desc = "Ensure proper 'formatoptions'",
})

vim.api.nvim_create_autocmd("User", {
  group = augroup("HideCopilotSuggestion"),
  pattern = "BlinkCmpMenuOpen",
  callback = function()
    require("copilot.suggestion").dismiss()
    vim.b.copilot_suggestion_hidden = true
  end,
  desc = "Hide Copilot suggestion when BlinkCmp menu is open",
})

vim.api.nvim_create_autocmd("User", {
  group = augroup("ShowCopilotSuggestion"),
  pattern = "BlinkCmpMenuClose",
  callback = function() vim.b.copilot_suggestion_hidden = false end,
  desc = "Show Copilot suggestion when BlinkCmp menu is closed",
})

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
