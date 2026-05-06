#!/bin/bash

WALLPAPER_DIR="${1:-$HOME/.config/walls}"
WALLPAPER_CONF="$HOME/.config/wallpaper.conf"

notify() { notify-send "switch-wallpaper" "$1"; }

set_wallpaper() {
    local wallpaper="$1"
    [[ ! -f "$wallpaper" ]] && { notify "File not found: $wallpaper"; return 1; }
    if xwallpaper --zoom "$wallpaper"; then
        echo "$wallpaper" > "$WALLPAPER_CONF"
    else
        notify "Failed to set wallpaper"
        return 1
    fi
}

path=$(wallpick "$WALLPAPER_DIR") || { notify "wallpick failed"; exit 1; }

set_wallpaper "$path"
