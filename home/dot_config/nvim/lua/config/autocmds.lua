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
    vim.hl.on_yank({ timeout = 100 })
    Utils.edit.restore_cursor()
  end,
  desc = "Highlight on yank and preserve cursor position",
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[vV\22]*:*",
  group = augroup("RestoreCursor"),
  callback = function() Utils.edit.restore_cursor() end,
  desc = "Try restoring cursor when leaving Visual mode",
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
  group = augroup("LastCursorPosition"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf

    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then return end

    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)

    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd("normal! zz")
    end
  end,
  desc = "Jump to last location in file",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("CloseWithQ"),
  pattern = {
    "checkhealth",
    "gitsigns-blame",
    "help",
    "qf",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
      end, { buffer = args.buf, silent = true, desc = "Quit buffer" })
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

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("BigfileSettings"),
  pattern = "bigfile",
  callback = function(args)
    local buf = args.buf
    local ft = vim.filetype.match({ buf = buf }) or ""
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:~:.")

    Snacks.notify.warn({
      ("Big file detected `%s`."):format(path),
      "Some Neovim features have been **disabled**.",
    }, { title = "Big File" })

    vim.api.nvim_buf_call(buf, function()
      if vim.fn.exists(":NoMatchParen") ~= 0 then vim.cmd([[NoMatchParen]]) end

      Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
      vim.b.minianimate_disable = true
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then vim.bo[buf].syntax = ft end
      end)
    end)
  end,
  desc = "Set options for bigfiles",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("LazyDiagnostic"),
  pattern = "lazy",
  once = true,
  callback = function() require("custom.lsp.diagnostic").setup() end,
  desc = "Set up diagnostic on 'Lazy' filetype, if it hasn't been setup",
})

local did_setup = false
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("BetterCheckhealth"),
  pattern = "checkhealth",
  callback = function(args)
    if args.file ~= "health://" then
      vim.notify(" Running Healthchecks…", vim.log.levels.INFO, { title = "vim.health" })
      return vim.schedule(function()
        vim.cmd("hi Cursor blend=100")
        vim.opt_local.guicursor:append("a:Cursor/lCursor")
        vim.api.nvim_win_set_config(0, { hide = true })
      end)
    end

    if did_setup then return end

    local ns_id = vim.api.nvim_create_namespace("checkhealth_icons")
    local icon_map = {
      ["✅"] = { icon = " ", hl = "@string" },
      ["⚠️"] = { icon = " ", hl = "@type" },
      ["❌"] = { icon = " ", hl = "@error" },
    }

    local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
    local extmarks = {}
    lines = vim.tbl_map(function(s)
      s = s:gsub("^%s", "")
      local ext = vim
        .iter(icon_map)
        :map(function(emoji, val)
          local col = s:find(emoji)
          if col ~= nil then
            s = s:gsub(emoji, val.icon)
            return { col - 1, col, val.hl }
          end
        end)
        :totable()

      table.insert(extmarks, ext)
      return s
    end, lines)

    local win = Snacks.win({
      show = false,
      border = "rounded",
      width = 0.8,
      height = 0.8,
      minimal = true,
      ft = "checkhealth",
      style = "minimal",
      wo = { concealcursor = "nvic" },
      title_pos = "center",
      title = {
        { "", "CheckHealthTitleBg" },
        { "  Checkhealth ", "CheckHealthTitle" },
        { "", "CheckHealthTitleBg" },
      },
      on_close = function() did_setup = false end,
    })

    ---@diagnostic disable-next-line: access-invisible
    local buf = win:open_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

    vim.schedule(function()
      vim.api.nvim_win_close(0, false)
      vim.cmd("hi Cursor blend=0")
      vim.opt_local.guicursor:remove("a:Cursor/lCursor")

      win:show()
      for i, line in ipairs(extmarks) do
        for _, ext in ipairs(line) do
          if vim.tbl_isempty(ext) then return end

          vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, ext[1], {
            end_col = ext[2],
            hl_group = ext[3],
          })
        end
      end

      did_setup = true
      vim.api.nvim_buf_set_name(win.buf or 0, "health://")
      vim.bo[0].filetype = "checkhealth"
    end)
  end,
  desc = "Better Floating Checkhealth",
})

vim.api.nvim_create_autocmd("User", {
  group = augroup("HideCopilotSuggestion"),
  pattern = "BlinkCmpMenuOpen",
  callback = function()
    if not package.loaded["copilot"] then return end

    local ok, copilot = pcall(require, "copilot.suggestion")
    if ok then copilot.dismiss() end

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

-- Remove the default TermClose autocmd
local default_term_close = vim.api.nvim_get_autocmds({
  group = "nvim.terminal",
  event = "TermClose",
})
vim.api.nvim_del_autocmd(default_term_close[1].id)

-- Readd the TermClose autocmd with a modification to only close terminal buffers not managed by the picker
vim.api.nvim_create_autocmd({ "TermClose" }, {
  group = default_term_close[1].group,
  nested = true,
  desc = "Automatically close terminal buffers when started with no arguments and exiting without an error",
  callback = function(args)
    if vim.v.event.status ~= 0 or vim.b[args.buf].managed_term then return end

    local info = vim.api.nvim_get_chan_info(vim.bo[args.buf].channel)
    local argv = info.argv or {}
    if table.concat(argv, " ") == vim.o.shell then vim.api.nvim_buf_delete(args.buf, { force = true }) end
  end,
})

---@param msg string
---@param level? vim.log.levels
---@param show? boolean
local function chezmoi_notify(msg, level, show)
  show = show or true
  if msg == "" or msg == nil or not show then return end
  vim.schedule(function() vim.notify(msg, level or vim.log.levels.INFO, { title = "Chezmoi" }) end)
end

---@param success_message? string
---@param handle_error? fun()
---@param opts? { verbose: boolean }
local function chezmoi_on_exit(success_message, handle_error, opts)
  local default_opts = { verbose = false }
  opts = vim.tbl_deep_extend("force", default_opts, opts or {})
  success_message = success_message or ""

  ---@param obj vim.SystemCompleted
  return function(obj)
    if obj.code == 0 then
      chezmoi_notify(success_message)
      return chezmoi_notify(obj.stdout, vim.log.levels.INFO, opts.verbose)
    end

    chezmoi_notify(obj.stdout, vim.log.levels.WARN, opts.verbose)
    chezmoi_notify(obj.stderr, vim.log.levels.WARN, opts.verbose)
    if handle_error then vim.schedule(handle_error) end
  end
end

---@param args string[]
---@param on_exit? fun(obj: vim.SystemCompleted)
local function chezmoi(args, on_exit) vim.system({ "chezmoi", unpack(args) }, { text = true }, on_exit) end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = augroup("ChezmoiApply"),
  pattern = vim.env.CHEZMOI_HOME .. "/**",
  callback = function()
    chezmoi({ "diff" }, function(obj)
      if obj.code ~= 0 or obj.stdout == "" then return end

      chezmoi(
        { "apply", "--no-tty", "-k" },
        chezmoi_on_exit("Successfully applied files", function()
          if vim.fn.confirm("Fix conflict?", "&Yes\n&No", 2) == 1 then
            require("custom.terminal").open({ "chezmoi", "apply" })
          end
        end)
      )
    end)
  end,
  desc = "Apply changes to chezmoi files after writing",
})

vim.api.nvim_create_autocmd("User", {
  group = augroup("ChezmoiUpdateLazyLock"),
  pattern = { "LazyDone", "LazyInstall", "LazyUpdate", "LazySync", "LazyClean" },
  callback = vim.schedule_wrap(function()
    local lock_file = vim.fs.normalize(vim.fn.stdpath("config") .. "/lazy-lock.json")

    chezmoi({ "diff", lock_file }, function(obj)
      if obj.code ~= 0 or obj.stdout == "" then return end

      chezmoi({ "add", lock_file }, chezmoi_on_exit("Successfully updated lazy-lock.json", nil, { verbose = true }))
    end)
  end),
})
