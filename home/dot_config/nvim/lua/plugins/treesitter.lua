return {
  {
    "nvim-treesitter/nvim-treesitter",
    priority = 200,
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0,
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      highlight = { enabled = true },
      indent = { enable = true },
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-CR>", -- Normal Mode
          scope_incremental = false, -- Visual Mode
          node_incremental = "<Tab>", -- Visual Mode
          node_decremental = "<BS>", -- Visual Mode
        },
      },
      -- stylua: ignore
      textobjects = {
        move = {
          enable = true,
          goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["],"] = "@parameter.inner" },
          goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[,"] = "@parameter.inner" },
          goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", },
        },
        swap = {
          enable = true,
          swap_next =     { [">,"] = "@parameter.inner" },
          swap_previous = { ["<,"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = Utils.dedup(opts.ensure_installed)
      end

      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "VeryLazy" },
    config = function()
      -- Rerun config again when nvim-treesitter is loaded
      if Utils.is_loaded("nvim-treesitter") then
        local opts = Utils.opts("nvim-treesitter")
        ---@diagnostic disable-next-line: missing-fields
        require("nvim-treesitter.configs").setup({ textobjects = opts.textobjects })
      end

      -- Use default c & C when in diff mode
      local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
      local configs = require("nvim-treesitter.configs")
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },
}
