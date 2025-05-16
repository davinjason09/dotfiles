return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      term_colors = true,
      compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
      styles = {
        comments = { "italic" },
        functions = { "bold" },
        operators = { "bold" },
        conditionals = { "bold" },
        loops = { "bold" },
        booleans = { "bold" },
      },
      default_integrations = false,
    })

    local palette = require("catppuccin.palettes").get_palette()
    Defaults.filling_palette(palette)
  end,
}
