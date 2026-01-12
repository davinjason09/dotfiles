return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0,
    build = function()
      package.loaded["utils.treesitter"] = nil
      require("nvim-treesitter").update(nil, { summary = true })
    end,
    cmd = { "TSUpdate", "TSUninstall", "TSInstall", "TSLog" },
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "comment",
        "css",
        "diff",
        "git_config",
        "gitignore",
        "html",
        "json",
        "printf",
        "regex",
        "vim",
      },
    },
    config = function(_, opts)
      if vim.fn.executable("tree-sitter") == 0 then
        return vim.notify("nvim-treesitter: tree-sitter CLI not found!", vim.log.levels.ERROR)
      elseif type(opts.ensure_installed) ~= "table" then
        return vim.notify(
          "nvim-treesitter: ensure_installed should be a table!",
          vim.log.levels.ERROR
        )
      end

      local TS = require("nvim-treesitter")
      TS.setup(opts)
      Utils.treesitter.get_installed(true)

      local needed = Utils.dedup(opts.ensure_installed)
      local install = vim.tbl_filter(
        function(lang) return not Utils.treesitter.have(lang) end,
        needed
      )

      if #install > 0 then
        TS.install(install, { summary = true })
          :await(function() Utils.treesitter.get_installed(true) end)
      end

      local installed = Utils.treesitter.get_installed()
      local uninstall = vim
        .iter(installed)
        :map(function(a) return not vim.tbl_contains(needed, a) and a end)
        :totable()

      if #uninstall > 0 then TS.uninstall(uninstall, { summary = true }) end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
        callback = function(ev)
          local ft = ev.match

          if not Utils.treesitter.have(ft) then return end

          if Utils.treesitter.have(ft, "highlights") then pcall(vim.treesitter.start, ev.buf) end

          -- stylua: ignore
          if Utils.treesitter.have(ft, "indents") then
            vim.api.nvim_set_option_value("indentexpr", "v:lua.Utils.treesitter.indentexpr()", { scope = "local" })
          end

          -- folds
          -- stylua: ignore
          if Utils.treesitter.have(ft, "folds") then
            vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local" })
            vim.api.nvim_set_option_value("foldexpr", "v:lua.Utils.treesitter.foldexpr()", { scope = "local" })
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "VeryLazy" },
    opts = {
      move = {
        enable = true,
        -- stylua: ignore
        keys = {
          goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["],"] = "@parameter.inner" },
          goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[,"] = "@parameter.inner" },
          goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", }
        },
      },
      swap = {
        enable = true,
        -- stylua: ignore
        keys = {
          swap_next =     { [">,"] = "@parameter.inner" },
          swap_previous = { ["<,"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      -- stylua: ignore
      local map = function(buf, key, type, method, query, desc)
        local mode = type == "move" and { "n", "x", "o" } or "n"
        vim.keymap.set(mode, key, function()
          require("nvim-treesitter-textobjects." .. type)[method](query, "textobjects")
        end, { buffer = buf, desc = desc, silent = true })
      end

      local function attach(buf)
        local ignored_ft = { "minifiles", "minifiles-help" }
        local ft = vim.bo[buf].filetype

        if vim.tbl_contains(ignored_ft, ft) then return end
        if not Utils.treesitter.have(ft, "textobjects") then return end

        for type, mappings in pairs(opts) do
          for method, keymaps in pairs(mappings.keys) do
            for key, query in pairs(keymaps) do
              local desc = query:gsub("@", ""):gsub("%..*", "")
              desc = desc:sub(1, 1):upper() .. desc:sub(2)
              desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc

              if type == "move" then
                desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
              end

              if not (vim.wo.diff and key:find("[cC]")) then
                map(buf, key, type, method, query, desc)
              end
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterTextObject", { clear = true }),
        callback = function(args) attach(args.buf) end,
      })

      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },
}
