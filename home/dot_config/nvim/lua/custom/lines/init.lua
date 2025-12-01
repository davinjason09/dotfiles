local M = {}

M._buflist_cache = {}

M.Statusline = require("custom.lines.statusline")

M.Tabline = require("custom.lines.tabline")

M.setup = function()
  local Comp = require("custom.lines.components")
  local U = require("custom.lines.utils")

  -- Setup clock update timer
  vim.uv.new_timer():start(
    (60 - tonumber(os.date("%S"))) * 1000,
    60000,
    vim.schedule_wrap(
      function() vim.api.nvim_exec_autocmds("User", { pattern = "UpdateTime", modeline = false }) end
    )
  )

  Comp.AI.setup()

  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
    callback = function()
      vim.schedule(function()
        local buffers = U.get_bufs()
        for i, v in ipairs(buffers) do
          M._buflist_cache[i] = v
        end

        for i = #buffers + 1, #M._buflist_cache do
          M._buflist_cache[i] = nil
        end

        if #M._buflist_cache > 1 then
          vim.o.showtabline = 2
        elseif vim.o.showtabline ~= 1 then -- otherwise it breaks startup screen
          vim.o.showtabline = 1
        end
      end)
    end,
  })

  -- HACK: update the showtabline to make sure the tabline macro component gets updated
  vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    callback = function()
      if #M._buflist_cache > 1 then
        vim.o.showtabline = 2
      elseif vim.o.showtabline ~= 1 then
        vim.o.showtabline = 1
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete", "TermOpen" }, {
    callback = function()
      local seen = {}
      local items = vim.tbl_map(function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)
        local parts = vim.split(path, "/")
        return {
          path = path,
          parts = parts,
          depth = 1,
          name = parts[#parts],
        }
      end, U.get_bufs())

      vim.iter(items):map(function(item) seen[item.name] = (seen[item.name] or 0) + 1 end)

      while true do
        local changes_made = false

        vim.iter(items):map(function(item)
          if seen[item.name] > 1 and item.depth < #item.parts then
            item.depth = item.depth + 1
            item.name = table.concat(item.parts, "/", #item.parts - item.depth + 1)
            seen[item.name] = (seen[item.name] or 0) + 1
            changes_made = true
          end
        end)

        if not changes_made then break end
      end

      local res = {}
      vim.iter(items):map(function(i)
        local parent_dir = table.concat(i.parts, "/", #i.parts - i.depth + 1, #i.parts - 1)
        local tail = i.parts[#i.parts]

        res[i.path] = {
          parent = parent_dir .. (parent_dir ~= "" and "/" or ""),
          tail = tail ~= "" and tail or "[No Name]",
        }
      end)

      ---@diagnostic disable-next-line: inject-field
      require("heirline").tabline.buf_map = res
    end,
  })
  -- Tab.setup()
end

return M
