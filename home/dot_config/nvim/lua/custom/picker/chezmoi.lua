local M = {}

---@class snacks.picker.chezmoi.Config: snacks.picker.files.Config
---@field kind string?
---@field finder fun(opts: snacks.picker.chezmoi.Config, ctx: snacks.picker.finder.ctx): snacks.picker.finder.result
M.source = {
  hidden = true,
  title = "Chezmoi Files",
  finder = function(opts, ctx)
    local cwd = vim.env.CHEZMOI_PATH .. (opts.kind and "/dot_config/" .. opts.kind or "")
    ctx.picker:set_cwd(cwd)

    if opts.kind and opts.kind ~= "" then ctx.picker.title = "Config Files" end

    return require("snacks.picker.source.proc").proc(
      ctx:opts({
        cwd = cwd,
        cmd = "fd",
        args = { "--type", "f", "--type", "l", "--color", "never", "-E", ".git" },
        notify = not opts.live,
        ---@param item snacks.picker.finder.Item
        transform = function(item)
          item.cwd = cwd
          item.file = item.text
        end,
      }),
      ctx
    )
  end,
}

return M
