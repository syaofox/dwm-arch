#!/bin/bash

# 主题目录 - 如果使用 dotfiles 软链接请调整

# 主题目录 - 软连接到 dotfiles 目录下的 .Xresources.d
THEME_DIR="$HOME/.Xresources.d"

# 稳健的主题枚举（处理名称中的空格）
AVAILABLE_THEMES=()
if [ -d "$THEME_DIR" ]; then
    while IFS= read -r -d '' theme; do
        theme_name=$(basename "$theme")
        [[ "$theme_name" != \#* ]] && AVAILABLE_THEMES+=("$theme_name")
    done < <(find "$THEME_DIR" -maxdepth 1 -mindepth 1 \( -type f -o -type l \) -print0 | sort -z)
fi

echo "Available themes: ${AVAILABLE_THEMES[*]}"

show_menu() {
    # 检查是否有可用主题
    if [ ${#AVAILABLE_THEMES[@]} -eq 0 ]; then
        dunstify -r 9988 -t 3000 "错误: 未找到主题文件在 $THEME_DIR"
        return 1
    fi
    
    local menu=""
    for theme in "${AVAILABLE_THEMES[@]}"; do
        menu="$menu$theme\n"
    done
    
    # 尝试带主题参数启动，失败则回退到无参数
    echo -e "$menu" | rofi -dmenu -p "Theme" -i -theme-str "listview { columns: 2; lines: 6;} " 2>/dev/null || \
    echo -e "$menu" | rofi -dmenu -p "Theme" -i
}

# 验证 GTK 主题是否存在于标准位置
validate_gtk_theme() {
    local theme="$1"
    local theme_paths=("$HOME/.themes" "$HOME/.local/share/themes" "/usr/share/themes")
    
    for base in "${theme_paths[@]}"; do
        if [ -d "$base/$theme" ]; then
            return 0
        fi
    done
    return 1
}

# 重启 xsettingsd 以应用更改
restart_xsettingsd() {
    if pgrep -x xsettingsd > /dev/null; then
        killall -HUP xsettingsd 2>/dev/null || killall xsettingsd 2>/dev/null && sleep 0.5
    fi
    
    # 如果 xsettingsd 未运行则启动
    if ! pgrep -x xsettingsd > /dev/null; then
        xsettingsd -c "$HOME/.config/xsettingsd/xsettingsd.conf" &
        disown
    fi
}

update_lightdm_greeter() {
    sudo /usr/local/bin/sync-lightdm-greeter.sh 2>/dev/null || true
}

switch_theme() {
    local theme="$1"
    local theme_file
    local base_theme

    # Xresources 使用完整主题名
    theme_file=$(readlink -f "$THEME_DIR/$theme")

    if [ ! -f "$theme_file" ]; then
        dunstify -r 9988 -t 2000 "主题 $theme 不存在"
        return 1
    fi

    echo "$theme" > "$HOME/.config/theme"

    # 先停 fcitx5（关闭时会覆写配置文件，必须在写入新配置前停止）
    if pgrep -x fcitx5 > /dev/null; then
        fcitx5-remote -e 2>/dev/null || true
        sleep 0.3
        pkill -f fcitx5 2>/dev/null || true
    fi
    systemctl stop --user fcitx5-daemon 2>/dev/null || true

    # 生成所有应用的配置文件
    if [ -f "$HOME/.local/bin/generate-app-themes.py" ]; then
        python3 "$HOME/.local/bin/generate-app-themes.py" "$theme_file"
    fi

    # 根据 DARK_THEME 设置 fcitx5 亮色/暗色主题
    dark_val=$(grep -m1 '^#define\s\+DARK_THEME\s\+[0-9]' "$theme_file" | awk '{print $3}')
    fcitx5_conf="$HOME/.config/fcitx5/conf/classicui.conf"
    if [ "$dark_val" = "1" ]; then
        # 深色 Xresources 主题 → 暗色
        sed -i 's/^Theme=.*/Theme=dwm-dark/' "$fcitx5_conf"
        sed -i 's/^DarkTheme=.*/DarkTheme=dwm-dark/' "$fcitx5_conf"
    else
        # 浅色 Xresources 主题 → 亮色
        sed -i 's/^Theme=.*/Theme=dwm/' "$fcitx5_conf"
        sed -i 's/^DarkTheme=.*/DarkTheme=dwm/' "$fcitx5_conf"
    fi

    # 应用 xfce4-terminal 配色
    xfce4_term_script="$HOME/.cache/xfce4-terminal-theme.sh"
    if [ -f "$xfce4_term_script" ]; then
        bash "$xfce4_term_script"
    fi

    # 验证 GTK 主题是否存在
    gtk_theme=$(grep -m1 '^gtk\.theme:' "$theme_file" | sed 's/^gtk\.theme:[[:space:]]*//')
    if [ -n "$gtk_theme" ] && ! validate_gtk_theme "$gtk_theme"; then
        dunstify -r 9988 -t 3000 "警告: GTK 主题 '$gtk_theme' 未找到，GTK 应用可能使用默认主题"
    fi

    # xsettingsd 配置已由 generate-app-themes.py 生成
    restart_xsettingsd

    xrdb -merge "$theme_file"

    pkill -USR1 dwm 2>/dev/null || true

    killall slstatus 2>/dev/null || true
    slstatus &

    killall dunst 2>/dev/null || true
    dunst &

    # 刷新 kitty 配色
    if command -v kitty &>/dev/null && kitty @ set-colors --all --configured "$HOME/.config/kitty/kitty.conf" &>/dev/null; then
        :
    fi

    # 启动 fcitx5 应用新主题
    fcitx5 -d &

    # 同步 LightDM greeter 主题
    update_lightdm_greeter

    dunstify -r 9988 -t 2000 "主题已切换: $theme"
}

main() {
    if [ -n "$1" ]; then
        theme="$1"
    else
        theme=$(show_menu)
    fi

    if [ -n "$theme" ]; then
        switch_theme "$theme"
    fi
}

main "$@"