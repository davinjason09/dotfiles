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
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
      ---@type table<string, conform.FileFormatterConfig>
      formatters = {
        biome = {
          args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
          append_args = function(_, ctx)
            if Utils.format.has_config(ctx.dirname, "biome") then return {} end
            return { "--config-path", vim.fs.joinpath(vim.fn.stdpath("config"), "rules", "biome.json") }
          end,
        },
        ["clang-format"] = {
          prepend_args = function(_, ctx)
            if Utils.format.has_config(ctx.dirname, "clang-format") then return {} end
            return { "-style=file:" .. vim.fs.joinpath(vim.fn.stdpath("config"), "rules", ".clang-format") }
          end,
        },
        injected = { options = { ignore_errors = true } },
        oxfmt = {
          prepend_args = function(_, ctx)
            if Utils.format.has_config(ctx.dirname, "oxfmt") then return {} end
            return { "-c", vim.fs.joinpath(vim.fn.stdpath("config"), "rules", ".oxfmtrc.json") }
          end,
        },
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
        stylua = {
          prepend_args = function(_, ctx)
            if Utils.format.has_config(ctx.dirname, "stylua") then return {} end
            return { "--config-path", vim.fs.joinpath(vim.fn.stdpath("config"), "rules", "stylua.toml") }
          end,
        },
      },
      formatters_by_ft = {
        astro = { "biome" },
        bash = { "shfmt" },
        bib = { "bibtex-tidy" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        css = { "oxfmt" },
        html = { "oxfmt" },
        java = { "clang-format" },
        javascript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        json = { "oxfmt" },
        lua = { "stylua" },
        markdown = { "oxfmt" },
        mdx = { "oxfmt" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        query = { lsp_format = "prefer" },
        sh = { "shfmt" },
        toml = { "tombi" },
        typescript = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        typst = { "injected", lsp_format = "prefer" },
        yaml = { "oxfmt" },
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
}
