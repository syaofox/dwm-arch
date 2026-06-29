#!/usr/bin/env bash

# 使用默认浏览器，没有则回退到 Firefox

set -e

export LANGUAGE=zh_CN
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# 无参数，启动浏览器首页
if [ $# -eq 0 ]; then
    if [ -n "$BROWSER" ]; then
        exec "$BROWSER"
    fi
    if command -v gtk-launch >/dev/null 2>&1; then
        default=$(xdg-settings get default-web-browser 2>/dev/null || true)
        if [ -n "$default" ]; then
            gtk-launch "${default%.desktop}"
            exit 0
        fi
    fi
    FIREFOX_APT="/usr/bin/firefox"
    if [ -x "$FIREFOX_APT" ]; then
        exec "$FIREFOX_APT"
    fi
    if command -v flatpak >/dev/null 2>&1 && flatpak info "org.mozilla.firefox" >/dev/null 2>&1; then
        exec flatpak run "org.mozilla.firefox"
    fi
    notify-send "未找到浏览器" "未找到浏览器" || true
    exit 1
fi

# $BROWSER 环境变量（最优先）
if [ -n "$BROWSER" ]; then
    exec "$BROWSER" "$@"
fi

# xdg-open（系统默认浏览器）
if command -v xdg-open >/dev/null 2>&1; then
    for url in "$@"; do
        xdg-open "$url" || true
    done
    exit 0
fi

# 回退：Firefox
FIREFOX_APT="/usr/bin/firefox"
FIREFOX_FLATPAK_ID="org.mozilla.firefox"

if [ -x "$FIREFOX_APT" ]; then
    exec "$FIREFOX_APT" "$@"
fi

if command -v flatpak >/dev/null 2>&1 && flatpak info "${FIREFOX_FLATPAK_ID}" >/dev/null 2>&1; then
    exec flatpak run "${FIREFOX_FLATPAK_ID}" "$@"
fi

notify-send "未找到浏览器" "未找到浏览器" || true
exit 1

