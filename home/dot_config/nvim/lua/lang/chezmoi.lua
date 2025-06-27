return {
  {
    "xvzc/chezmoi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "ChezmoiEdit" },
    keys = {
      { "<leader>sz", function() Utils.picker.chezmoi() end, desc = "[S]earch Che[z]moi File" },
    },
    opts = {
      edit = {
        watch = false,
        force = false,
      },
      events = {
        on_open = { notification = { enable = false } },
        on_watch = { notification = { enable = false } },
        on_apply = { notification = { msg = "Successfully applied file" } },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
        callback = function() vim.schedule(require("chezmoi.commands.__edit").watch) end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "gotmpl" },
    },
  },
  {
    "echasnovski/mini.icons",
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
