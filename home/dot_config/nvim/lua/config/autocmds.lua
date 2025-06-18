local function augroup(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("CheckTime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
  desc = "Check if we need to reload the file when it changed",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("HighlightYank"),
  callback = function()
    vim.hl.on_yank()
    Utils.coding.restore_cursor()
  end,
  desc = "Highlight on yank and preserve cursor position",
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("ResizeSplits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
  desc = "Resize splits if window got resized",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf

    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then return end

    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)

    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
  desc = "Jump to last location in file",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("CloseWithQ"),
  pattern = {
    "checkhealth",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "query",
    "qf",
  },
  callback = function(args)
    if vim.bo[args.buf].filetype == "query" and vim.bo[args.buf].buftype ~= "nofile" then return end

    vim.bo[args.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
      end, {
        buffer = args.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
  desc = "Close certain buffer with <q>",
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
