return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0,
    build = function() vim.cmd.TSUpdate() end,
    cmd = { "TSUpdate", "TSUninstall", "TSInstall", "TSLog" },
    opts_extend = { "ensure_installed" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "comment",
        "css",
        "diff",
        "git_config",
        "gitignore",
        "html",
        "printf",
        "query",
        "regex",
        "vim",
        "vimdoc",
      },
    },
    config = function(_, opts)
      if vim.fn.executable("tree-sitter") == 0 then
        return vim.notify("nvim-treesitter: tree-sitter CLI not found!", vim.log.levels.ERROR)
      end

      if type(opts.ensure_installed) ~= "table" then
        return vim.notify(
          "nvim-treesitter: ensure_installed should be a table!",
          vim.log.levels.ERROR
        )
      end

      -- require("nvim-treesitter.configs").setup(opts)
      local TS = require("nvim-treesitter")
      TS.setup(opts)

      local needed = Utils.dedup(opts.ensure_installed)
      Utils.ui.installed_parser = TS.get_installed("parsers")

      local install = vim.tbl_filter(function(lang) return not Utils.ui.have(lang) end, needed)

      if #install > 0 then
        TS.install(install, { summary = true })
          :await(function() Utils.ui.installed_parser = TS.get_installed("parsers") end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if Utils.ui.have(ev.match) then pcall(vim.treesitter.start) end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "VeryLazy" },
    keys = function()
      -- stylua: ignore
      local keys = {
        moves = {
          goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["],"] = "@parameter.inner" },
          goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[,"] = "@parameter.inner" },
          goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", },
        },
        swap = {
          swap_next     = { [">,"] = "@parameter.inner" },
          swap_previous = { ["<,"] = "@parameter.inner" },
        },
      }

      local ret = {}
      for type, mappings in pairs(keys) do
        for method, keymaps in pairs(mappings) do
          for key, query in pairs(keymaps) do
            local desc = query:gsub("@", ""):gsub("%..*", "")
            desc = desc:sub(1, 1):upper() .. desc:sub(2)
            desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
            if type == "move" then
              desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
            end
            ret[#ret + 1] = {
              key,
              function()
                -- don't use treesitter if in diff mode and the key is one of the c/C keys
                if vim.wo.diff and key:find("[cC]") then return vim.cmd("normal! " .. key) end
                require("nvim-treesitter-textobjects." .. type)[method](query, "textobjects")
              end,
              desc = desc,
              mode = { "n", "x", "o" },
              silent = true,
            }
          end
        end
      end
      return ret
    end,
    config = function(_, opts) require("nvim-treesitter-textobjects").setup(opts) end,
  },
}
