#!/bin/bash

# ================== 加载用户环境 ==================
# 确保 startx 能读取到 .profile 中的环境变量（如 PATH）
[ -f "$HOME/.profile" ] && . "$HOME/.profile"


# 环境变量
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



# ================== 5. 确保 D-Bus 会话已启动 ==================
# 如果系统脚本没有启动，或你想确保唯一性，这里作为兜底
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# ================== 6. 启动 GNOME Keyring（直接启动） ==================
# 不使用 PAM 自动解锁，守护进程需手动解锁或使用空密码
eval "$(gnome-keyring-daemon --start --components=secrets,ssh)" &
export SSH_AUTH_SOCK
export GNOME_KEYRING_CONTROL

# ================== 7. 其他会话级服务 ==================
# PolicyKit 认证代理（用于 GUI 授权弹窗）
[ -x /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 ] && \
    /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &


exec dwm