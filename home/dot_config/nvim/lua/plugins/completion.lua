return {
  "Saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    { "L3MON4D3/LuaSnip", version = "v2.0" },
    { "rafamadriz/friendly-snippets" },
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
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      ghost_text = { enabled = true },
    },
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
    snippets = { preset = "luasnip" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          timeout_ms = 500,
          opts = { tailwind_color_icon = Defaults.icons.kind.Color },
        },
        buffer = { max_items = 5 },
        cmdline = {
          min_keyword_length = function(ctx)
            if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then return 3 end
            return 0
          end,
        },
      },
    },
    keymap = {
      preset = "none",
      ["<A-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },
      ["<BS>"] = {
        function(cmp)
          if cmp.is_menu_visible() then cmp.cancel() end

          local bs = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
          vim.defer_fn(function() vim.fn.feedkeys(bs, "n") end, 1)
        end,
      },

      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },

      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
    },
    cmdline = {
      completion = {
        list = { selection = { auto_insert = false } },
        menu = {
          auto_show = function() return vim.fn.getcmdtype() == ":" end,
          draw = {
            columns = { { "kind_icon" }, { "label" }, { "kind" } },
          },
        },
      },
      sources = function()
        local type = vim.fn.getcmdtype()

        if type == "/" or type == "?" then return { "buffer" } end

        -- HACK:
        -- Disable cmdline completion for shell command (!) because it makes neovim hangs.
        -- Only allow completion if ("!%w+$") is not found in the line
        if type == ":" and not vim.fn.getcmdline():match("!%w+$") then return { "cmdline" } end

        return {}
      end,
      keymap = {
        preset = "none",
        ["<A-Space>"] = { "show", "fallback" },
        ["<Tab>"] = { "show_and_insert", "accept" },
        ["<C-Right>"] = { "accept", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
      },
    },
  },
}
