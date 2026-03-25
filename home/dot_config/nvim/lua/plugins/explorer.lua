return {
  {
    "nvim-mini/mini.files",
    version = "*",
    lazy = vim.fn.argc(-1) == 0,
    opts = {
      mappings = {
        go_in_plus = "<CR>",
        go_out = "H",
        go_out_plus = "h",
        reveal_cwd = ".",
        show_help = "?",
      },
      options = {
        permanent_delete = false,
        use_as_default_explorer = false,
      },
      windows = {
        width_focus = 30,
        width_nofocus = 20,
      },
      content = { prefix = Utils.get_icon },
    },
    keys = {
      {
        "<leader>e",
        function()
          local MiniFiles = _G.MiniFiles or require("mini.files")
          local buf_name = vim.api.nvim_buf_get_name(0)
          local dir_name = vim.fn.fnamemodify(buf_name, ":p:h")

          -- Open the directory of the currently edited file
          -- IF it doesn't exist, open cwd()
          local path = vim.uv.cwd()
          if vim.fn.filereadable(buf_name) == 1 then
            path = buf_name
          elseif vim.fn.isdirectory(dir_name) then
            path = dir_name
          end

          MiniFiles.open(path, true)
        end,
        desc = "Explorer",
      },
      {
        "<leader>ET",
        function()
          local MiniFiles = _G.MiniFiles or require("mini.files")
          MiniFiles.open(vim.fn.stdpath("data") .. "/mini.files/trash", true)
        end,
        desc = "[E]xplorer: [T]rash",
      },
    },
    config = function(_, opts)
      local MiniFiles = require("mini.files")
      MiniFiles.setup(opts)

      -- HACK:
      -- If we set `use_as_default_explorer` to true, with how this config is setup, the options.lua
      -- will never be applied, and when pressing `q` or the explorer is out of focus, it will leave
      -- the editor not being set properly and leave the terminal section of the Snacks dashboard on
      -- the screen.
      -- So as a workaround, we disable `use_as_default_explorer` and do this instead on a scheduled
      -- event.
      if vim.fn.argc(-1) ~= 0 then
        local arg = vim.fn.argv(0) --[[@as string]]
        if vim.fn.isdirectory(arg) == 1 then vim.schedule(MiniFiles.open) end
      end

      -- NOTE:
      -- Handle cases when we open another floating window that makes the explorer to be out of focus
      if Snacks then
        local pick = Snacks.picker.pick
        ---@type fun(source?: string, opts?: snacks.picker.Config)
        Snacks.picker.pick = function(source, opts) ---@diagnostic disable-line
          MiniFiles.close()
          return pick(source, opts)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lazy" },
        callback = function()
          local win = vim.fn.win_getid()
          MiniFiles.close()
          vim.fn.win_gotoid(win)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowOpen",
        callback = function(ev)
          local win_id = ev.data.win_id

          local config = vim.api.nvim_win_get_config(win_id)
          config.border = "rounded"
          vim.api.nvim_win_set_config(win_id, config)
        end,
        desc = "Set rounded border for MiniFiles",
      })

      -- Integrate MiniFiles with LSP for file operations
      local group = vim.api.nvim_create_augroup("MiniFilesLSP", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "MiniFilesActionRename", "MiniFilesActionMoved" },
        callback = function(ev) Snacks.rename.on_rename_file(ev.data.from, ev.data.to) end,
        desc = "LSP integrated file rename",
      })

      local function request_and_notify_lsp(request_method, notif_method, changes)
        local clients = vim.lsp.get_clients
        for _, client in pairs(clients({ method = request_method })) do
          local resp = client:request_sync(request_method, changes, 1000, 0)
          if resp and resp.result ~= nil then vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding) end
        end

        for _, client in pairs(clients({ method = notif_method })) do
          client:notify(notif_method, changes)
        end
      end

      local function on_create_file(name)
        local changes = { files = { {
          uri = vim.uri_from_fname(name),
        } } }

        request_and_notify_lsp("workspace/willCreateFile", "workspace/didCreateFile", changes)
      end

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MiniFilesActionCreate",
        callback = function(ev) on_create_file(ev.data.to) end,
        desc = "LSP integrated file create",
      })

      local function on_delete_file(name)
        local changes = { files = { {
          uri = vim.uri_from_fname(name),
        } } }

        request_and_notify_lsp("workspace/willDeleteFiles", "workspace/didDeleteFiles", changes)
      end

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MiniFilesActionDelete",
        callback = function(ev) on_delete_file(ev.data.from) end,
        desc = "LSP integrated file delete",
      })

      -- Yank the path of the current file in MiniFiles
      local yank_path = function()
        local path = (MiniFiles.get_fs_entry() or {}).path
        if path == nil then return vim.notify("Cursor is not on valid entry") end
        vim.fn.setreg(vim.v.register, path)
      end

      -- Toggle visibility of dotfiles in MiniFiles
      local show_dotfiles = true

      local filter_show = function() return true end
      local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        MiniFiles.refresh({ content = { filter = new_filter } })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(ev)
          local buf = ev.data.buf_id
          local map = vim.keymap.set

          map({ "n", "i", "x" }, "<C-s>", function()
            if vim.fn.mode() ~= "n" then Utils.edit.escape() end
            vim.defer_fn(MiniFiles.synchronize, 0)
          end, { buffer = buf, desc = "Synchronize" })
          map("n", "gy", yank_path, { buffer = buf, desc = "Yank path" })
          map("n", "g.", toggle_dotfiles, { buffer = buf, desc = "Toggle dotfiles" })
        end,
      })

      local set_mark = function(id, path, desc) MiniFiles.set_bookmark(id, path, { desc = desc }) end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesExplorerOpen",
        callback = function()
          set_mark("d", "~/dotfiles", "Dotfiles")
          set_mark("w", vim.fn.getcwd, "Working directory")
          set_mark("~", "~", "Home directory")
        end,
      })
    end,
  },
  {
    "snacks.nvim",
    opts = {
      explorer = { replace_netrw = false },
      picker = {
        sources = {
          explorer = {
            layout = {
              auto_hide = { "input" },
              layout = { width = 35, min_width = 35, position = "right" },
              cycle = false,
            },
            win = {
              list = {
                keys = {
                  ["<leader>/"] = false,
                  ["<C-BS>"] = { "<C-S-w>", mode = { "i" }, expr = true },
                },
              },
            },
            hidden = true,
            ignored = true,
            git_status_open = true,
          },
        },
      },
    },
    keys = {
      {
        "<leader>Et",
        function()
          -- https://github.com/folke/snacks.nvim/discussions/1273
          local explorers = Snacks.picker.get({ source = "explorer" })
          for _, v in pairs(explorers) do
            if v:is_focused() then
              v:close() -- Close focussed explorer
            else
              v:focus() -- Focus unfocussed explorer
            end
          end

          -- Open explorer if there's none opened
          if #explorers == 0 then Snacks.explorer() end
        end,
        desc = "[E]xplorer: [T]ree",
      },
    },
  },
}
