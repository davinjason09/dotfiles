return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0,
    build = function() require("nvim-treesitter").update(nil, { summary = true }) end,
    cmd = { "TSUpdate", "TSUninstall", "TSInstall", "TSLog" },
    opts_extend = { "ensure_installed" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      folds = { enable = true },
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
        "vimdoc",
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
      Utils.ui.get_installed(true)

      local needed = Utils.dedup(opts.ensure_installed)
      local install = vim.tbl_filter(function(lang) return not Utils.ui.have(lang) end, needed)

      if #install > 0 then
        TS.install(install, { summary = true }):await(function() Utils.ui.get_installed(true) end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
        callback = function(ev)
          if not Utils.ui.have(ev.match) then return end

          if vim.tbl_get(opts, "highlight", "enable") ~= false then pcall(vim.treesitter.start) end

          -- stylua: ignore
          if vim.tbl_get(opts, "indent", "enable") ~= false and Utils.ui.have(ev.match, "indents") then
            Utils.set_default("indentexpr", "v:lua.Utils.ui.indentexpr()")
          end

          -- folds
          if vim.tbl_get(opts, "folds", "enable") ~= false and Utils.ui.have(ev.match, "folds") then
            if Utils.set_default("foldmethod", "expr") then
              Utils.set_default("foldexpr", "v:lua.Utils.ui.foldexpr()")
            end
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

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterTextObject", { clear = true }),
        callback = function(args)
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
                  map(args.buf, key, type, method, query, desc)
                end
              end
            end
          end
        end,
      })
    end,
  },
}
