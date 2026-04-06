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
  callback = function(ev)
    local exclude = { "gitcommit" }
    local buf = ev.buf

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
    "gitsigns-blame",
    "help",
    "qf",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { buffer = ev.buf, silent = true, desc = "Quit buffer" })
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
  callback = function(ev)
    local buf = ev.buf
    local ft = vim.filetype.match({ buf = buf }) or ""
    local path = vim.fs.relpath(".", vim.api.nvim_buf_get_name(buf))

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

---@return integer?
local function get_checkhealth_win()
  local wins = vim.api.nvim_list_wins()

  for _, id in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(id)
    if vim.bo[buf].ft == "checkhealth" then return id end
  end

  return nil
end

vim.api.nvim_create_autocmd("Progress", {
  group = augroup("BetterCheckhealth"),
  pattern = { "vim.health" },
  callback = function(ev)
    local data = ev.data
    if data.status ~= "success" then
      vim.notify_once(" Running Healthchecks…", vim.log.levels.INFO, { title = "vim.health" })

      vim.cmd("hi Cursor blend=100")
      vim.opt_local.guicursor:append("a:Cursor/lCursor")

      vim.bo[ev.buf].filetype = "checkhealth"
      vim.api.nvim_win_set_config(0, { hide = true })
      return
    end

    local ns_id = vim.api.nvim_create_namespace("checkhealth_icons")
    local icon_map = {
      ["✅"] = { icon = " ", hl = "@string" },
      ["⚠️"] = { icon = " ", hl = "@type" },
      ["❌"] = { icon = " ", hl = "@error" },
    }

    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    local extmarks = {}
    lines = vim.tbl_map(function(s)
      s = s:gsub("^%s", "")
      -- stylua: ignore
      local ext = vim.iter(icon_map):map(function(emoji, val)
        local col = s:find(emoji)
        if col ~= nil then
          s = s:gsub(emoji, val.icon)
          return { col - 1, col, val.hl }
        end
      end):totable()

      table.insert(extmarks, ext)
      return s
    end, lines)

    local win = Snacks.win({
      show = false,
      style = "small_float",
      title_pos = "center",
      border = "rounded",
      wo = { signcolumn = "no" },
      title = {
        { "", "CheckHealthTitleBg" },
        { "  Checkhealth ", "CheckHealthTitle" },
        { "", "CheckHealthTitleBg" },
      },
    })

    ---@diagnostic disable-next-line: access-invisible
    local buf = win:open_buf() ---@type integer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

    local issue_url = assert(Utils.report({ open = false }))
    _G.nvim_bugreport_open = function() vim.ui.open(issue_url) end

    vim.schedule(function()
      vim.cmd("hi Cursor blend=0")
      vim.opt_local.guicursor:remove("a:Cursor/lCursor")

      local che_win = get_checkhealth_win()
      if not che_win then
        return vim.notify("No checkhealth window found!", vim.log.levels.ERROR, { title = "vim.health" })
      end

      vim.api.nvim_win_close(che_win, false)
      win:show()

      for i, line in ipairs(extmarks) do
        for _, ext in ipairs(line) do
          if vim.tbl_isempty(ext) then return end
          vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, ext[1], { end_col = ext[2], hl_group = ext[3] })
        end
      end

      local w = win:win_valid() and win.win ---@type integer
      vim.api.nvim_buf_set_name(buf, "health://")
      vim.bo[buf].filetype = "checkhealth"
      vim.wo[w].winbar = "%#CheckHealthReport#%@v:lua.nvim_bugreport_open@ Click to Create Bug Report on GitHub%X%*"

      vim.api.nvim_create_autocmd("BufDelete", {
        buffer = buf,
        once = true,
        command = "lua _G.nvim_bugreport_open = nil",
      })
    end)
  end,
  desc = "Fancy Checkhealth",
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
  callback = function(ev)
    if vim.v.event.status ~= 0 or vim.b[ev.buf].managed_term then return end

    local info = vim.api.nvim_get_chan_info(vim.bo[ev.buf].channel)
    local argv = info.argv or {}
    if table.concat(argv, " ") == vim.o.shell then vim.api.nvim_buf_delete(ev.buf, { force = true }) end
  end,
})

---@param msg string
---@param level? vim.log.levels
---@param show? boolean
local function chezmoi_notify(msg, level, show)
  if (msg == "" or msg == nil) or (show ~= nil and not show) then return end

  level = level or vim.log.levels.INFO
  vim.schedule(function() vim.notify(vim.trim(msg), level, { title = "Chezmoi", id = "chezmoi" }) end)
end

---@param success_message? string
---@param handle_error? fun()
---@param opts? { verbose: boolean }
local function chezmoi_on_exit(success_message, handle_error, opts)
  opts = vim.tbl_deep_extend("force", { verbose = false }, opts or {})
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
            Snacks.picker.terminal({ cmd = { "chezmoi", "apply" } }) ---@diagnostic disable-line: undefined-field
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
    local lock_file = vim.fs.joinpath(vim.fn.stdpath("config"), "lazy-lock.json")

    chezmoi({ "diff", lock_file }, function(obj)
      if obj.code ~= 0 or obj.stdout == "" then return end

      chezmoi({ "add", lock_file }, chezmoi_on_exit("Successfully updated lazy-lock.json", nil, { verbose = true }))
    end)
  end),
})
