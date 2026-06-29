#!/usr/bin/env bash

# Rofi 网页启动器 - 改进版
# 配置文件位置: ~/.config/rofi/websites.txt
# 文件格式: 显示名称|URL
# 例如:
#   Google|https://www.google.com
#   GitHub|https://github.com

# set -euo pipefail  # 严格模式

export LANGUAGE=zh_CN
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

CONFIG_FILE="${HOME}/.config/rofi/websites.txt"
declare -A SITE_URLS=()
declare -a SITE_NAMES=()

# 1. 加载网站列表
if [[ -f "$CONFIG_FILE" ]]; then
    while IFS='|' read -r name url; do
        [[ -z "$name" || -z "$url" ]] && continue
        SITE_URLS["$name"]="$url"
        SITE_NAMES+=("$name")
    done < "$CONFIG_FILE"
else
    # 默认内置列表（当配置文件不存在时使用）
    SITE_URLS=(
        ["Google"]="https://www.google.com"
        ["GitHub"]="https://github.com"        
        ["Arch Wiki"]="https://wiki.archlinux.org"
        ["HomePage"]="http://10.10.10.6:8888"
    )
    SITE_NAMES=("Google" "GitHub" "Arch Wiki" "HomePage")
fi

# 2. 生成显示给 Rofi 的列表（按配置文件顺序）
menu_items=$(printf "%s\n" "${SITE_NAMES[@]}")

# 3. 调用 Rofi 获取用户选择
selected=$(echo "$menu_items" | rofi -dmenu -p " Open website" -i -l 10 -theme theme)

# 4. 如果用户没有选择（ESC 或取消），则退出
if [[ -z "$selected" ]]; then
    exit 0
fi

# 5. 获取对应的 URL
url="${SITE_URLS[$selected]}"
if [[ -z "$url" ]]; then
    echo "错误: 未找到 '$selected' 对应的 URL" >&2
    exit 1
fi

open_url() {
    local url="$1"

    # 检测正在运行的浏览器，优先开新标签
    for proc in brave-browser-stable brave-browser brave-origin-nightly; do
        if pgrep -x "$proc" >/dev/null 2>&1 && command -v brave >/dev/null 2>&1; then
            brave --new-tab "$url"
            return
        fi
    done

    for proc in google-chrome google-chrome-stable chrome chromium chromium-browser; do
        if pgrep -x "$proc" >/dev/null 2>&1 && command -v "$proc" >/dev/null 2>&1; then
            "$proc" "$url"
            return
        fi
    done

    if pgrep -x firefox >/dev/null 2>&1 && command -v firefox >/dev/null 2>&1; then
        firefox --new-tab "$url"
        return
    fi

    # 无运行中的浏览器时，使用系统默认
    xdg-open "$url"
}

open_url "$url"