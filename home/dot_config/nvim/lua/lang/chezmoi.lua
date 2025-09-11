return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "gotmpl" },
    },
  },
  {
    "nvim-mini/mini.icons",
    -- stylua: ignore
    opts = {
      file = {
        [".chezmoiignore"]  = { glyph = "", hl = "MiniIconsGrey" },
        [".chezmoiremove"]  = { glyph = "", hl = "MiniIconsGrey" },
        [".chezmoiroot"]    = { glyph = "", hl = "MiniIconsGrey" },
        [".chezmoiversion"] = { glyph = "", hl = "MiniIconsGrey" },
        -- Chezmoi tmpl files
        ["dot_zshrc.tmpl"]      = { glyph = "", hl = "MiniIconsGrey" },
        ["dot_zshenv.tmpl"]     = { glyph = "", hl = "MiniIconsGrey" },
        ["dot_zprofile.tmpl"]   = { glyph = "", hl = "MiniIconsGrey" },
        ["dot_gitconfig.tmpl"]  = { glyph = "", hl = "MiniIconsGrey" },
        [".chezmoiignore.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
      },
      extension = {
        ["bash.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["json.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["ps1.tmpl"]  = { glyph = "󰨊", hl = "MiniIconsGrey" },
        ["sh.tmpl"]   = { glyph = "", hl = "MiniIconsGrey" },
        ["toml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["yaml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
        ["zsh.tmpl"]  = { glyph = "", hl = "MiniIconsGrey" },
      },
    },
  },
}
