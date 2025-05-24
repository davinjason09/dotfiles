return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    event = { "BufReadPre", "BufNewFile", "VeryLazy" },
    opts_extend = { "ensure_installed" },
    opts = { ui = { icons = Defaults.mason_icons } },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(
          function()
            require("lazy.core.handler.event").trigger({
              event = "FileType",
              buffer = vim.api.nvim_get_current_buf(),
            })
          end,
          100
        )
      end)

      ---@param msg string
      ---@param level? vim.log.levels | integer
      local function notify(msg, level)
        level = level or vim.log.levels.INFO
        vim.notify(msg, level, { title = "Mason.nvim" })
      end

      mr.refresh(function()
        Utils.dedup(opts.ensure_installed)
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)

          if not p:is_installed() then
            local handle_closed = function()
              local level = vim.log.levels.INFO
              local msg

              if p:is_installed() then
                msg = ("%s was successfully installed."):format(p.name)
              else
                msg = ("Failed to install %s. See :MasonLog"):format(p.name)
                level = vim.log.levels.ERROR
              end

              notify(msg, level)
            end

            notify(("Installing %s..."):format(p.name))
            p:install():once("closed", handle_closed)
          end
        end
      end)
    end,
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPost", "BufWritePre" },
    cmd = "ConformInfo",
    init = function()
      Utils.on_very_lazy(function()
        Utils.format.formatter = {
          name = "conform.nvim",
          format = function() require("conform").format({ bufnr = 0 }) end,
        }
      end)
    end,
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
      formatters = {
        injected = { options = { ignore_errors = true } },
      },
      formatters_by_ft = {
        lua = { "stylua" },
      },
      format_on_save = function()
        -- Don't format when minifiles is open
        if vim.g.minifiles_active then return nil end

        -- Stop if we disabled auto-formatting.
        if not vim.g.autoformat then return nil end

        return {}
      end,
    },
  },
}
