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

        -- remove installed package that are no longer in the ensure_installed list
        for _, tool in ipairs(mr.get_installed_package_names()) do
          if not vim.tbl_contains(opts.ensure_installed, tool) then
            local p = mr.get_package(tool)
            if p:is_installed() then
              local handle_closed = function()
                notify(("%s was successfully uninstalled."):format(p.name))
              end

              notify(("%s is no longer used. Uninstalling..."):format(p.name))
              p:uninstall():once("closed", handle_closed)
            end
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
          format = function(buf) require("conform").format({ async = true, bufnr = buf }) end,
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
        ["clang-format"] = {
          prepend_args = function(_, ctx)
            if not Utils.format.has_config(ctx.dirname, "clang-format") then
              return { "-style=file:" .. vim.fn.stdpath("config") .. "/rules/.clang-format" }
            end
          end,
        },
        stylua = {
          prepend_args = function(_, ctx)
            if not Utils.format.has_config(ctx.dirname, "stylua") then
              return { "--config-path", vim.fn.stdpath("config") .. "/rules/stylua.toml" }
            end
          end,
        },
        taplo = {
          append_args = function(_, ctx)
            if not Utils.format.has_config(ctx.dirname, "taplo") then
              return { "--config", vim.fn.stdpath("config") .. "/rules/taplo.toml" }
            end
          end,
        },
      },
      formatters_by_ft = {
        bash = { "shfmt" },
        bib = { "bibtex-tidy" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        toml = { "taplo" },
        typst = { "typstyle", lsp_format = "prefer" },
        yaml = { "prettier" },
        zsh = { "shfmt" },
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = function()
        -- Don't format when minifiles is open
        if vim.g.minifiles_active then return nil end

        -- Stop if we disabled auto-formatting.
        if not vim.g.autoformat then return nil end

        return { lsp_format = "fallback" }
      end,
    },
  },
  {
    "felpafel/inlay-hint.nvim",
    event = "LspAttach",
    opts = { virt_text_pos = "eol" },
  },
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "folke/snacks.nvim" },
    },
    opts = {
      backend = "vim",
      picker = {
        "snacks",
        opts = { layout = "dropdown" },
      },
    },
  },
}
