return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPost", "BufWritePre" },
    cmd = "ConformInfo",
    init = function()
      Utils.on_very_lazy(function()
        Utils.format.formatter = {
          name = "conform.nvim",
          format = function(buf) require("conform").format({ bufnr = buf }) end,
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
        prettier = {
          prepend_args = function() return { "--parser", vim.bo.filetype } end,
        },
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },
        stylua = {
          prepend_args = function(_, ctx)
            if not Utils.format.has_config(ctx.dirname, "stylua") then
              return { "--config-path", vim.fn.stdpath("config") .. "/rules/stylua.toml" }
            end
          end,
        },
      },
      formatters_by_ft = {
        bash = { "shfmt" },
        bib = { "bibtex-tidy" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        query = { lsp_format = "prefer" },
        sh = { "shfmt" },
        toml = { "tombi" },
        typst = { "typstyle", lsp_format = "prefer" },
        yaml = { "prettier" },
        zsh = { "shfmt" },
        ["_"] = { "trim_whitespace" },
      },
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
      picker = { "snacks", opts = { layout = "dropdown" } },
    },
  },
}
