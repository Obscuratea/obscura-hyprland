# Obscura for Hyprland

The [Obscura](https://github.com/Obscuratea/obscura-theme) look on Hyprland + [Noctalia](https://github.com/noctalia-dev): sharp corners,
flat opaque surfaces, 2px borders, Geist Mono / Archivo / Inter. Colors are **not** fixed: Noctalia derives
them from your wallpaper, so changing wallpaper recolors the borders, bar, terminals and GTK/Qt apps together.

## What it changes
- Hyprland: rounding 0, no blur/shadow, opacity 1, loaded last so it overrides defaults
- Alacritty: removes hard-coded colors/font/opacity so the Noctalia theme and Geist Mono apply
- Noctalia: square bar, Hyprland color template enabled
- Fonts: installed to `~/.local/share/fonts/obscura`

## Install / undo
```bash
./install.sh     # backs up first, to ~/.local/share/obscura-hyprland/
./uninstall.sh   # restores the latest backup
```
Tested on CachyOS, Hyprland 0.56 (Lua config), Noctalia. MIT licensed; fonts are separate OFL works.
