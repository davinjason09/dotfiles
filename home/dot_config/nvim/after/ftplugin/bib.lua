vim.api.nvim_buf_create_user_command(0, "GetBib", function(ctx)
  if not vim.fn.executable("bibget") then
    return vim.notify("`bibget` binary is not found in PATH", vim.log.levels.ERROR)
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local buf = vim.api.nvim_get_current_buf()

  vim.notify("Getting BibTex...", vim.log.levels.INFO)
  vim.system({ "bibget", unpack(ctx.fargs) }, function(obj)
    if obj.stderr ~= "" then return vim.notify(vim.trim(obj.stderr), vim.log.levels.ERROR) end
    if obj.stdout == "" then return vim.notify("BibTex not found", vim.log.levels.WARN) end

    vim.schedule(function()
      local out = obj.stdout:gsub("\n  \n", "\n"):gsub("\n\n", "\n"):gsub("\n$", "")
      vim.api.nvim_buf_set_lines(buf, row, row, true, vim.split(out, "\n"))
      vim.cmd("checktime")
    end)
  end)
end, {
  desc = "Get BibTex output from given doi link(s)",
  nargs = "+",
})
