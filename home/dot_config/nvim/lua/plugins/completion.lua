return {
  "Saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    { "L3MON4D3/LuaSnip", version = "v2.0" },
    { "rafamadriz/friendly-snippets" },
  },
  ---@type blink.cmp.Config
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
        auto_show_delay_ms = 250,
        window = {
          scrollbar = false,
          border = "rounded",
        },
        draw = function(opts)
          -- Modified from: https://github.com/OXY2DEV/nvim/blob/main/lua/plugins/lsp.lua#L168
          local buf = opts.window.buf ---@type integer
          local src_buf = vim.api.nvim_get_current_buf()

          local lines = {}

          if opts.item and opts.item.documentation then
            lines = vim.split(opts.item.documentation.value or "", "\n", { trimempty = true })
          end

          local details = vim.split(opts.item.detail or "", "\n", { trimempty = true })

          if #details > 0 then
            table.insert(details, 1, string.format("```%s", vim.bo[src_buf].ft or ""))
            table.insert(details, "```")
          end

          if #lines > 0 and lines[1] ~= "---" then table.insert(lines, 1, "---") end

          local visible_lines = vim.list_extend(details, lines)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, visible_lines)

          local win = opts.window:get_win()
          local render = require("render-markdown.core.ui").update

          if win then
            vim.bo[buf].ft = "markdown"
            render(buf, win, "BlinkDraw", true)
            vim.bo[buf].ft = "blink-cmp-documentation"
          end

          vim.defer_fn(function()
            win = opts.window:get_win()
            if win then
              vim.bo[buf].ft = "markdown"
              render(buf, win, "BlinkDraw", true)
              vim.bo[buf].ft = "blink-cmp-documentation"
            end
          end, 25)
        end,
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
      },
    },
    keymap = {
      preset = "none",
      ["<C-h>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },
      ["<BS>"] = {
        ---@param cmp blink.cmp.API
        function(cmp)
          if cmp.is_menu_visible() then cmp.cancel() end

          local BS = Snacks.util.keycode("<BS>")
          vim.fn.feedkeys(BS, "n")
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
        ["<C-h>"] = { "show", "fallback" },
        ["<Tab>"] = { "show_and_insert", "accept" },
        ["<C-Right>"] = { "accept", "fallback" },
        ["<CR>"] = {
          ---@param cmp blink.cmp.API
          function(cmp)
            if cmp.get_selected_item() and cmp.is_menu_visible() then
              cmp.accept()
            else
              local CR = Snacks.util.keycode("<CR>")
              vim.fn.feedkeys(CR, "n")
            end
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
