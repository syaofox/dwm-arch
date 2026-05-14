#!/bin/bash
set -Eeuo pipefail

[ -f "$HOME/.profile" ] && . "$HOME/.profile"

export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_DESKTOP=dwm
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
export DOCKER_BUILDKIT=1

xset dpms 0 0 900
xset s 600 s noblank
xss-lock -- slock -m "Single is simple, double is double." &

if [ -f "$HOME/.config/theme" ]; then
    THEME=$(cat "$HOME/.config/theme")
else
    THEME="tokyonight"
fi

xrdb -merge ~/.Xresources
if [ -f "$HOME/.Xresources.d/${THEME}" ]; then
    xrdb -merge "$HOME/.Xresources.d/${THEME}"
fi

if [ ! -f "$HOME/.config/theme" ] && [ -f "$HOME/.local/bin/generate-app-themes.py" ] && [ -n "$THEME" ] && [ -f "$HOME/.Xresources.d/${THEME}" ]; then
    python3 "$HOME/.local/bin/generate-app-themes.py" "$HOME/.Xresources.d/${THEME}"
fi

[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ] && \
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

exec dwm
