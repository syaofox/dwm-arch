#!/usr/bin/env bash

# Rofi 网页启动器 - 改进版
# 配置文件位置: ~/.config/rofi/websites.txt
# 文件格式: 显示名称|URL
# 示例:
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

is_browser_running() {
    local browser_process="$1"
    pgrep -x "$browser_process" > /dev/null 2>&1
}

command_exists() {
    command -v "$1" > /dev/null 2>&1
}

open_url() {
    local url="$1"
    local browser_cmd=""

    local brave_running=false
    local chrome_running=false
    local firefox_running=false

    for proc in brave-browser-stable brave-browser; do
        if is_browser_running "$proc"; then
            brave_running=true
            break
        fi
    done

    if ! $brave_running; then
        for proc in google-chrome google-chrome-stable chrome chromium chromium-browser; do
            if is_browser_running "$proc"; then
                chrome_running=true
                break
            fi
        done
    fi

    if ! $brave_running && ! $chrome_running; then
        if is_browser_running firefox; then
            firefox_running=true
        fi
    fi

    if $brave_running && command_exists brave; then
        browser_cmd="brave --new-tab"
    elif $chrome_running; then
        for proc in google-chrome google-chrome-stable chrome chromium chromium-browser; do
            if command_exists "$proc"; then
                browser_cmd="$proc"
                break
            fi
        done
    elif $firefox_running && command_exists firefox; then
        browser_cmd="firefox --new-tab"
    fi

    if [[ -z "$browser_cmd" ]]; then
        xdg-open "$url"
    else
        if [[ "$browser_cmd" == *" "* ]]; then
            sh -c "${browser_cmd} '${url}'"
        else
            "$browser_cmd" "$url"
        fi
    fi
}

open_url "$url"