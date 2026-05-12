#!/bin/bash
# 环境变量
export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_DESKTOP=dwm
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
export DOCKER_BUILDKIT=1


# X基础设置
# xset -dpms
# xset s off
# xset s noblank

# 设置屏幕保护和电源管理
xset dpms 0 0 900
xset s 600 s noblank
xss-lock -- slock -m "Single is simple, double is double." &

# 主题逻辑加载
if [ -f "$HOME/.config/theme" ]; then
    THEME=$(cat "$HOME/.config/theme")
else
    THEME="tokyonight"
fi

# 加载 Xresources
xrdb -merge ~/.Xresources
if [ -f "$HOME/.Xresources.d/${THEME}" ]; then
    xrdb -merge "$HOME/.Xresources.d/${THEME}"
fi

# 生成主题 (首次启动时，.config/theme 不存在说明未运行过 switch-theme.sh)
if [ ! -f "$HOME/.config/theme" ] && [ -f "$HOME/.local/bin/generate-app-themes.py" ] && [ -n "$THEME" ] && [ -f "$HOME/.Xresources.d/${THEME}" ]; then
    python3 "$HOME/.local/bin/generate-app-themes.py" "$HOME/.Xresources.d/${THEME}"
fi

exec dwm