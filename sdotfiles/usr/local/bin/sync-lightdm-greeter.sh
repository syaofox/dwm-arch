#!/bin/bash
set -euo pipefail

USER_HOME=$(getent passwd "${SUDO_USER:-}" | cut -d: -f6)
if [[ -z "$USER_HOME" ]]; then
    echo "ERROR: must be run via sudo" >&2
    exit 1
fi

THEME=$(cat "$USER_HOME/.config/theme" 2>/dev/null || echo "tokyonight")
THEME_FILE="$USER_HOME/.Xresources.d/$THEME"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "Warning: theme file not found: $THEME_FILE, using defaults" >&2
fi

GTK_THEME=$(grep -m1 '^#define\s\+LIGHTDM_GTK_THEME\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+LIGHTDM_GTK_THEME\s\+//') || GTK_THEME=$(grep -m1 '^#define\s\+GTK_THEME\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+GTK_THEME\s\+//') || GTK_THEME="Mint-Y-Purple"
GTK_ICON=$(grep -m1 '^#define\s\+LIGHTDM_GTK_ICON\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+LIGHTDM_GTK_ICON\s\+//') || GTK_ICON=$(grep -m1 '^#define\s\+GTK_ICON\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+GTK_ICON\s\+//') || GTK_ICON="Mint-Y-Purple"
GTK_FONT=$(grep -m1 '^#define\s\+GTK_FONT\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+GTK_FONT\s\+//') || GTK_FONT="Noto Sans 11"

WALLPAPER_CONF="$USER_HOME/.config/wallpaper.conf"
DEFAULT_WALL="$USER_HOME/.config/walls/nord.png"
if [[ -f "$WALLPAPER_CONF" ]]; then
    WALLPAPER=$(cat "$WALLPAPER_CONF")
else
    WALLPAPER="$DEFAULT_WALL"
fi

mkdir -p /etc/lightdm
if [[ -f "$WALLPAPER" ]]; then
    cp "$WALLPAPER" /etc/lightdm/background.png
else
    echo "Warning: wallpaper not found: $WALLPAPER" >&2
fi

cat > /etc/lightdm/lightdm-gtk-greeter.conf << CONF
[greeter]
background = /etc/lightdm/background.png
theme-name = ${GTK_THEME}
icon-theme-name = ${GTK_ICON}
font-name = ${GTK_FONT}
CONF
