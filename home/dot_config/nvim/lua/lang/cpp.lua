return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "doxygen",
      },
    },
  },
  {
    "saghen/blink.pairs",
    ---@type blink.pairs.Config
    opts = {
      mappings = {
        pairs = {
          ["{"] = {
            {
              "{",
              "};",
              when = function(ctx)
                local text = ctx:text_before_cursor()

                for _, keyword in ipairs({ "class", "struct", "enum", "union" }) do
                  if text:match(keyword) then return true end
                end

                return false
              end,
              languages = { "cpp" },
            },
            { "}", enter = false, space = false },
          },
        },
      },
    },
  },
}
