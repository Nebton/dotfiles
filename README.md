# My Dotfiles

Welcome to my dotfiles! This configuration is heavily inspired by **Berserk** and features a custom setup using [AGS (Aylur's GTK Shell)](https://github.com/Aylur/ags/) along with **Hyprland**.

## Features

- **Window Manager**: Hyprland for dynamic tiling and smooth performance.
- **Shell**: Custom GTK theming using [AGS](https://github.com/Aylur/ags/).
- **Inspired by**: The aesthetics of the manga/anime **Berserk**.

## Screenshots

Here are some screenshots of my desktop setup:

### AGS in Action
![AGS Example 1](./ags/AGS1.png)

### Custom Configurations
![AGS Example 2](./ags/AGS2.png)

## Getting Started

To use this configuration:

1. Clone the repository:
    ```bash
    git clone https://github.com/Nebton/dotfiles.git
    cd dotfiles
    ```
2. Install Hyprland, Hyprpaper 0.8+, **AGS 1.8.2** (`aylurs-gtk-shell`),
   GJS, and the dependencies used by your widgets. This config uses the AGS 1 API.
3. Link the desktop configuration and compatibility launcher:
    ```bash
    mkdir -p ~/.config ~/.local/bin ~/.local/share/ags-compat
    # Back up existing files/directories before replacing them with these links.
    ln -s "$PWD/hypr" ~/.config/hypr
    ln -s "$PWD/ags" ~/.config/ags
    ln -s "$PWD/Scripts" ~/Scripts
    ln -s "$PWD/wallpaper_colors.conf" ~/.config/wallpaper_colors.conf
    ln -s "$PWD/local/bin/ags" ~/.local/bin/ags
    ln -s "$PWD/local/share/ags-compat/launcher.js" ~/.local/share/ags-compat/launcher.js
    ```
   The wallpaper script also updates the existing Kitty, Rofi, Neovim, and Zsh
   configurations. Link those directories to `~/.config/` as appropriate.
4. Put your wallpapers in `~/Wallpapers` with matching entries in
   `wallpaper_colors.conf`. Update the `/home/doom` paths in `hypr/hyprland.conf`
   if installing for another user.
5. Restart Hyprland to run the startup commands.

## Desktop controls and compatibility

- **Super+R** selects a wallpaper and applies its theme colors. Hyprpaper uses a
  `wallpaper` block with an empty monitor to cover all connected displays.
- **Super+W** starts the widgets; **Super+Shift+W** closes them.
- `local/bin/ags` sets typelib/library paths before launching the tracked AGS 1
  entry point. This avoids the removed static GIRepository calls in newer GJS,
  without changing package-managed files in `/usr/bin`.
- Tray buttons bind each application's icon and tooltip; left click activates
  the application (or opens its menu when requested), right click opens its menu.
- Wallpaper logs are written to `~/.local/state/hypr/hyprpaper.log`.

## Notes

- These dotfiles are optimized for a system running **Hyprland** with a GTK environment.
- Ensure you have all dependencies installed as required by [AGS](https://github.com/Aylur/ags/).




