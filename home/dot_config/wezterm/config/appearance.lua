local wez = require("wezterm") ---@type Wezterm

return {
  -- Fonts
  font_size = 7.5,
  command_palette_font_size = 7.75,
  char_select_font_size = 7.75,

  font = wez.font_with_fallback({
    "JetBrainsMono Nerd Font",
    { family = "Segoe UI Emoji", assume_emoji_presentation = false },
    { family = "JuliaMono", assume_emoji_presentation = false },
  }),

  font_rules = {
    {
      intensity = "Bold",
      italic = false,
      -- stylua: ignore
      font = wez.font_with_fallback({
        { family = "JetBrainsMono Nerd Font", weight = "Bold" },
        { family = "Segoe UI Emoji",          weight = "Bold", assume_emoji_presentation = false },
        { family = "JuliaMono",               weight = "Bold", assume_emoji_presentation = false },
      }),
    },
    {
      intensity = "Normal",
      italic = true,
      -- stylua: ignore
      font = wez.font_with_fallback({
        { family = "JetBrainsMono Nerd Font", style = "Italic" },
        { family = "Segoe UI Emoji",          style = "Italic", assume_emoji_presentation = false },
        { family = "JuliaMono",               style = "Italic", assume_emoji_presentation = false },
      }),
    },
    {
      intensity = "Bold",
      italic = true,
      -- stylua: ignore
      font = wez.font_with_fallback({
        { family = "JetBrainsMono Nerd Font", weight = "Bold", style = "Italic" },
        { family = "Segoe UI Emoji",          weight = "Bold", style = "Italic", assume_emoji_presentation = false },
        { family = "JuliaMono",               weight = "Bold", style = "Italic", assume_emoji_presentation = false },
      }),
    },
  },

  line_height = 1.05,
  underline_thickness = 2,
  underline_position = -4,
  freetype_load_target = "Normal",
  anti_alias_custom_block_glyphs = true,
  custom_block_glyphs = true,

  -- Theme
  color_scheme = "Catppuccin Mocha",
  colors = {
    split = "#89DCEB",
  },

  -- Window
  window_padding = {
    left = 0,
    right = 0,
    top = 1,
    bottom = 0,
  },
  window_frame = {
    font = wez.font(
      "JetBrainsMono Nerd Font",
      { weight = "Bold", stretch = "Normal", style = "Normal" }
    ),
    font_size = 9,
  },

  -- Cursor
  default_cursor_style = "SteadyBar",
}
