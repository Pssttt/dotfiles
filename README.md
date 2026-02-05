# Dotfiles

Personal config files managed with Stow.

## Setup

Clone this repo and run the setup script.

```bash
git clone https://github.com/Pssttt/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

The script will list available packages and let you install them by number,
multiple numbers, or all at once. Enter 0 to exit.

## Packages (for now)

- aerospace - Window manager
- fastfetch
- fish - Shell config
- gitconfig - Git settings
- lazygit
- nvim - Neovim config
- sketchybar - Menu bar
- spotify-player
- wezterm - Terminal
- zsh - Shell config

## How it works

Each directory contains config files organized in subdirectories (e.g., `.config/nvim`).
Stow symlinks them to your home directory without copying files.

## Updating packages

Since configs are symlinked, any changes made are instantly reflected in both locations.
