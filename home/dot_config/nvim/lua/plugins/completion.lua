return {
  "Saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    { "L3MON4D3/LuaSnip", version = "v2.0" },
    { "rafamadriz/friendly-snippets" },
    { "MeanderingProgrammer/render-markdown.nvim" },
  },
  opts = {
    appearance = { kind_icons = Defaults.icons.kind },
    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      menu = {
        border = "rounded",
        draw = {
          align_to = "cursor",
          columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
          treesitter = { "lsp" },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 100,
        window = {
          scrollbar = false,
          min_width = 30,
          border = "rounded",
        },
        ---@param opts blink.cmp.CompletionDocumentationDrawOpts
        draw = function(opts)
          local buf = opts.window.buf ---@type integer
          local win = opts.window:get_win()

          local parsed = require("custom.blink.documentation").parse(opts)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, parsed)

          local render = require("render-markdown").render

          if win then
            vim.bo[buf].ft = "blink-cmp-documentation"
            vim.schedule(function() render({ buf = buf, event = "BlinkDraw" }) end)
          end

          vim.defer_fn(function()
            win = opts.window:get_win()

            if win then
              vim.bo[buf].ft = "blink-cmp-documentation"
              vim.schedule(function() render({ buf = buf, event = "BlinkDraw" }) end)
            end
          end, 25)
        end,
      },
      ghost_text = { enabled = true },
    },
    signature = {
      enabled = true,
      window = {
        border = "rounded",
        show_documentation = true,
      },
    },
    snippets = { preset = "luasnip" },
    sources = {
      per_filetype = {
        lua = { "lazydev", "lsp", "path", "snippets" },
        query = { "lsp", "omni", "buffer" },
      },
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          timeout_ms = 500,
          opts = { tailwind_color_icon = Defaults.icons.kind.Color },
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          fallbacks = { "lsp" },
          score_offset = 100,
        },
        buffer = { max_items = 5 },
      },
    },
    keymap = {
      preset = "none",
      ["<C-l>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },

      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },

      ["<C-u>"] = { "scroll_documentation_up", "scroll_signature_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "scroll_signature_down", "fallback" },
    },
    cmdline = {
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          auto_show = function() return vim.fn.getcmdtype() == ":" end,
          draw = { columns = { { "kind_icon" }, { "label" }, { "kind" } } },
        },
        ghost_text = { enabled = true },
      },
      sources = function()
        local type = vim.fn.getcmdtype()

        if type == "/" or type == "?" then return { "buffer" } end
        if type == ":" then return { "cmdline" } end

        return {}
      end,
      keymap = {
        preset = "none",
        ["<C-l>"] = { "show", "fallback" },
        ["<Tab>"] = { "show_and_insert", "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },

        ["<C-Right>"] = { "accept", "fallback" },
        ["<CR>"] = {
          ---@param cmp blink.cmp.API
          function(cmp)
            if (cmp.is_visible() and cmp.get_selected_item()) or cmp.is_ghost_text_visible() then
              return cmp.accept()
            end

            return vim.fn.feedkeys(Snacks.util.keycode("<CR>"), "n")
          end,
        },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
      },
    },
  },
  config = function(_, opts)
    local blink = require("blink.cmp")
    blink.setup(opts)

    vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities(Defaults.capabilities, true) })
  end,
}
