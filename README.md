<h1 align="center">dotfiles</h1>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<div align="center">
  <p>
    <a href="https://github.com/davinjason09/dotfiles/commits/main/"><img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/davinjason09/dotfiles?display_timestamp=author&style=for-the-badge&logo=github&logoColor=cdd6f4&logoSize=auto&label=Last%20Commit&labelColor=313244&color=f2cdcd"></a>&nbsp;&nbsp;
    <a href="https://github.com/davinjason09/dotfiles/"><img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/davinjason09/dotfiles?style=for-the-badge&logo=hackthebox&logoColor=cdd6f4&label=Repo%20Size&color=b4befe"></a>
  </p>
</div>

> [!WARNING]
> This repository is a work in progress. \
> This repo will contain my configuration files for various apps that I use daily. Most of the things included are meant for my own use and may not work for everybody. Only use this as a reference and "borrow" whatever interests you.

![Desktop](/assets/Screenshot_2025-06-19_002340.jpg)

## Core System Info

- **OS**: Windows 11, Arch WSL2
- **WM**: GlazeWM
- **Shell**: zsh
- **Terminal**: Wezterm
- **Panel**: Yasb
- **Editor**: Neovim
- **Browser**: Zen-Browser
- **File Manager**: Yazi
- **Colorscheme**: Catppuccin Mocha

## TODO

- [x] Use chezmoi
- [~] Add configs to the repo
  - [x] Add nvim from scratch
    - [x] Bisect what plugin slowing down buffer opening
    - [x] Fix dependencies of plugins
    - [x] Modularize some plugins with heavy customization into its separate folder (eg. heirline, incline)
    - [x] Custom picker (nvim_options, reload plugin, chezmoi files)
    - [x] Custom blink-documentation parser for better docs (esp. typst)
    - [~] Custom terminal manager
    - [ ] Migrate nvim-treesitter to main branch
  - [x] zsh
    - [x] Optimize startup time (~780ms to ~300ms)
    - [x] Polish scripts
    - [x] migrate from zap to znap
  - [x] yazi
    - [x] Custom catppuccin
    - [x] Yatline
  - [ ] wezterm
    - [ ] Modularize config
  - [x] glazewm
  - [x] yasb
  - [x] windhawk
  - [x] kanata
  - [ ] zen-browser
    - [ ] userChrome.css
    - [ ] user.js
- [ ] Add a script to install all the dependencies
- [x] Add a script to copy files to the windows side
- [~] Gallery
  - [ ] Add more screenshots of my setup
  - [~] Individual README for each config

Checkbox Items:

- "x" = Finished
- "~" = In Progress
- " " = Not Started
- "-" = Cancelled

---

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
</p>
