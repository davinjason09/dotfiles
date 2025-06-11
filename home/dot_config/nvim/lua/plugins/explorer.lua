return {
  {
    "echasnovski/mini.files",
    version = "*",
    opts = {
      mappings = {
        go_in_plus = "<CR>",
        go_out = "H",
        go_out_plus = "h",
        reveal_cwd = ".",
        show_hekp = "?",
      },
      options = {
        permanent_delete = false,
        use_as_default_explorer = true,
      },
      windows = {
        width_focus = 30,
        width_nofocus = 20,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          local dir_name = vim.fn.fnamemodify(buf_name, ":p:h")

          -- Open the directory of the currently edited file
          -- IF it doesn't exist, open cwd()
          local path = nil
          if vim.fn.filereadable(buf_name) == 1 then
            path = buf_name
          elseif vim.fn.isdirectory(dir_name) then
            path = dir_name
          else
            path = vim.uv.cwd()
          end

          MiniFiles.open(path, true)
        end,
        desc = "Explorer",
      },
      {
        "<leader>ET",
        function() MiniFiles.open(vim.fn.stdpath("data") .. "/mini.files/trash", true) end,
        desc = "[E]xplorer: [T]rash",
        silent = true,
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowOpen",
        callback = function(args)
          local win_id = args.data.win_id

          local config = vim.api.nvim_win_get_config(win_id)
          config.border = "rounded"
          vim.api.nvim_win_set_config(win_id, config)
        end,
        desc = "Set rounded border for MiniFiles",
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
        desc = "LSP integrated file rename",
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
        callback = function(args)
          local bufnr = args.data.buf_id
          local map = vim.keymap.set
          local ESC = Snacks.util.keycode("<Esc>")

          map({ "n", "i", "x" }, "<C-s>", function()
            if vim.fn.mode() ~= "n" then vim.api.nvim_feedkeys(ESC, "n", false) end
            vim.defer_fn(MiniFiles.synchronize, 0)
          end, { buffer = bufnr, desc = "Synchronize" })
          map("n", "gy", yank_path, { buffer = bufnr, desc = "Yank path" })
          map("n", "g.", toggle_dotfiles, { buffer = bufnr, desc = "Toggle dotfiles" })
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
    keys = { { "<leader>Et", function() Snacks.explorer() end, desc = "[E]xplorer: [T]ree" } },
  },
}
