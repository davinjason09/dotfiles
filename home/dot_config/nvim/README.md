<div align="center" style="display: flex; align-items: center; flex-direction: row; justify-content: center;">
  <img src="https://upload.wikimedia.org/wikipedia/commons/3/3a/Neovim-mark.svg" alt="neovim" width="35px" style="display: inline;">
  <span style="margin-left: 10px; font-size: 2em; font-weight: bold;">neovim</span>
</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600" />
</p>

<div align="center">
  <a href="https://github.com/neovim/neovim/releases/tag/stable">
    <img
      alt="Neovim Version Capability"
      src="https://img.shields.io/badge/Supports%20Nvim-v0.11-A6D895?style=for-the-badge&colorA=363A4F&logo=neovim&logoColor=D9E0EE">
  </a>&nbsp;&nbsp;
  <img src="https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=CDD6F4" />
</div>

<br>

![Neovim](assets/nvim.jpg)

---

## Quick Start

### Requirements

- [Neovim v0.11+](https://github.com/neovim/neovim/releases/tag/stable) (this config uses the new `vim.lsp` API)
- [Git](https://git-scm.com/) for plugin management
- [A Nerd Font](https://www.nerdfonts.com/) like `JetBrains Mono Nerd Font` for icons
- [Ripgrep](https://github.com/BurntSushi/ripgrep) for faster file search
- A C compiler for nvim-treesitter. See [here](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
- curl for [blink.cmp](https://github.com/Saghen/blink.cmp) (completion engine)
- A terminal that support true color and UTF-8 support
  - [Kitty](https://github.com/kovidgoyal/kitty) (Linux & MacOS)
  - [Ghostty](https://github.com/ghostty-org/ghostty/) (Linux & MacOS)
  - [Wezterm](https://github.com/wez/wezterm) (Linux, MacOS & Windows)
  - [alacritty](https://github.com/alacritty/alacritty) (Linux, MacOS & Windows)

> [!WARNING]
> **Note:**
>
> - The Dashboard logo uses glyphs from `Symbols for Legacy Computing`, make sure your terminal supports it

## Features

- Lazy loading with [lazy.nvim](https://github.com/folke/lazy.nvim)
- Extensive use of [snacks.nvim](https://github.com/folke/snacks.nvim) including custom pickers
- Custom statusline built with [heirline.nvim](https://github.com/rebelot/heirline.nvim)
- Completions with [blink.cmp](https://github.com/Saghen/blink.cmp)
- Extensive use of [mini.icons](https://github.com/echasnovski/mini.icons) throughout the config for a cohesive appearance
- Custom terminal manager (also a picker in disguise)
- Custom cmdline and message events views (soon)

---

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" width="1000"/>
</p>
