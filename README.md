# dwm-arch

Provisioning scripts and dotfiles for deploying a DWM desktop environment on a minimal Arch Linux installation.

## Quick Start

```bash
# On a fresh Arch Linux system (run as non-root with sudo)
./install.sh
```

## Structure

| Path | Description |
|------|-------------|
| `setup/` | 27 provisioning scripts (locale, packages, DWM, apps, etc.) |
| `dotfiles/` | User-level config (`~/.config/`, `~/.local/bin/`, etc.) |
| `sdotfiles/` | System-level config (`/etc/`, `/usr/`) |
| `sbin/` | Admin scripts (btrfs, zram, sysctl) |
| `tools/` | Utility scripts (config backup/restore) |
| `install.sh` | Main orchestrator — runs all `setup/` scripts |

> **Re-deploy dotfiles**: Run `./setup/deploy-dotfiles.sh` to re-deploy user configs from `dotfiles/` to `~` (creates backups before overwriting). Similarly, `./setup/deploy-sdotfiles.sh` for system configs.

## Custom Scripts (`~/.local/bin/`)

- `dwmcmd.sh` — DWM command dispatcher (menu, yazi, lock, screenshot, etc.)
- `switch-theme.sh` — Interactive rofi theme switcher
- `switch-wallpaper.sh` — Wallpaper picker
- `generate-app-themes.py` — Theme engine: renders templates from Xresources colors
- `show-keys.sh` — DWM keyboard shortcut reference
- `volume.sh` — Volume control with notifications

## Theme System

Colors defined in `~/.Xresources.d/` (5 themes included). The theme engine (`generate-app-themes.py`) reads Xresources `#define` entries and generates configs for dunst, rofi, kitty, yazi, GTK2/3/4, Qt5/6, xsettingsd, fcitx5, and neovim.

## License

MIT
