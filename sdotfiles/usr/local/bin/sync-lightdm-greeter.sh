#!/bin/bash
set -euo pipefail

USER_HOME=$(getent passwd "${SUDO_USER:-}" | cut -d: -f6)
if [[ -z "$USER_HOME" ]]; then
    echo "ERROR: must be run via sudo" >&2
    exit 1
fi

THEME=$(cat "$USER_HOME/.config/theme" 2>/dev/null || echo "tokyonight")
THEME_FILE="$USER_HOME/.Xresources.d/$THEME"

GTK_THEME=$(grep -m1 '^#define\s\+LIGHTDM_GTK_THEME\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+LIGHTDM_GTK_THEME\s\+//') || GTK_THEME=$(grep -m1 '^#define\s\+GTK_THEME\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+GTK_THEME\s\+//') || GTK_THEME="Mint-Y-Purple"
GTK_ICON=$(grep -m1 '^#define\s\+LIGHTDM_GTK_ICON\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+LIGHTDM_GTK_ICON\s\+//') || GTK_ICON=$(grep -m1 '^#define\s\+GTK_ICON\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+GTK_ICON\s\+//') || GTK_ICON="Mint-Y-Purple"
GTK_FONT=$(grep -m1 '^#define\s\+GTK_FONT\s\+' "$THEME_FILE" 2>/dev/null | sed 's/^#define\s\+GTK_FONT\s\+//') || GTK_FONT="Noto Sans 11"
WALLPAPER=$(cat "$USER_HOME/.config/wallpaper.conf" 2>/dev/null || echo "$USER_HOME/.config/walls/nord-2.png")

mkdir -p /etc/lightdm
[[ -f "$WALLPAPER" ]] && cp "$WALLPAPER" /etc/lightdm/background.png

cat > /etc/lightdm/lightdm-gtk-greeter.conf << CONF
[greeter]
background = /etc/lightdm/background.png
theme-name = ${GTK_THEME}
icon-theme-name = ${GTK_ICON}
font-name = ${GTK_FONT}
CONF
