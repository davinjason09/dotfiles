local C = require("heirline.conditions")

return {
  condition = C.lsp_attached,
  update = { "BufEnter", "FileType", "LspAttach", "LspDetach", "VimResized" },
  on_click = {
    callback = function()
      vim.defer_fn(function() vim.cmd("LspInfo") end, 100)
    end,
    name = "lsp_info",
  },
  provider = function()
    local attached = Utils.get_lsp_clients()

    local lsp_info = ""
    if #attached == 0 then
      lsp_info = ""
    elseif #attached == 1 then
      lsp_info = ("  %s "):format(attached[1])
    else
      lsp_info = ("  [%s] "):format(table.concat(attached, ", "))
    end

    if C.width_percent_below(#lsp_info, 0.2) then
      return lsp_info
    else
      local n = #attached
      return n >= 1 and ("  %s LSP%s "):format(n, n == 1 and "" or "s") or ""
    end
  end,
}
