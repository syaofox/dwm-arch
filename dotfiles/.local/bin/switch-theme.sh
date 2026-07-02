#!/bin/bash
set -Eeuo pipefail

THEME_DIR="$HOME/.Xresources.d"

log_info()  { echo "[$(date +'%H:%M:%S')] INFO: $*"; }
log_warn()  { echo "[$(date +'%H:%M:%S')] WARN: $*" >&2; }
log_error() { echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2; }

notify_user() {
    local msg="$1" duration="${2:-2000}"
    if command -v dunstify &>/dev/null; then
        dunstify -r 9988 -t "$duration" "$msg" 2>/dev/null || true
    fi
}

check_deps() {
    local missing=()
    for cmd in python3 rofi xrdb; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        notify_user "错误: 缺少依赖 ${missing[*]}" 3000
        return 1
    fi
    return 0
}

AVAILABLE_THEMES=()
if [[ -d "$THEME_DIR" ]]; then
    while IFS= read -r -d '' theme; do
        theme_name=$(basename "$theme")
        [[ "$theme_name" != \#* ]] && AVAILABLE_THEMES+=("$theme_name")
    done < <(find "$THEME_DIR" -maxdepth 1 -mindepth 1 \( -type f -o -type l \) -print0 | sort -z)
fi

show_menu() {
    if [[ ${#AVAILABLE_THEMES[@]} -eq 0 ]]; then
        notify_user "错误: 未找到主题文件在 $THEME_DIR" 3000
        return 1
    fi

    local menu
    menu=$(printf "%s\n" "${AVAILABLE_THEMES[@]}")

    local choice
    choice=$(echo -e "$menu" | rofi -dmenu -p "Theme" -i \
        -theme-str "listview { columns: 2; lines: 6; }" 2>/dev/null) || \
    choice=$(echo -e "$menu" | rofi -dmenu -p "Theme" -i 2>/dev/null) || true

    [[ -z "$choice" ]] && return 1
    echo "$choice"
}

validate_gtk_theme() {
    local theme="$1"
    local theme_paths=("$HOME/.themes" "$HOME/.local/share/themes" "/usr/share/themes")
    for base in "${theme_paths[@]}"; do
        [[ -d "$base/$theme" ]] && return 0
    done
    return 1
}

restart_xsettingsd() {
    if pgrep -x xsettingsd &>/dev/null; then
        killall -HUP xsettingsd 2>/dev/null || { killall xsettingsd 2>/dev/null && sleep 0.5; } || true
    fi
    if ! pgrep -x xsettingsd &>/dev/null; then
        xsettingsd -c "$HOME/.config/xsettingsd/xsettingsd.conf" &
        disown
    fi
}

update_lightdm_greeter() {
    if command -v sudo &>/dev/null && [[ -x /usr/local/bin/sync-lightdm-greeter.sh ]]; then
        sudo /usr/local/bin/sync-lightdm-greeter.sh 2>/dev/null || log_warn "LightDM greeter sync failed"
    fi
}

_graceful_kill() {
    local name="$1" timeout="${2:-2}"
    if ! pgrep -x "$name" &>/dev/null; then
        return 0
    fi
    killall "$name" 2>/dev/null || true
    local waited=0
    while pgrep -x "$name" &>/dev/null && [[ $waited -lt $timeout ]]; do
        sleep 0.2
        waited=$((waited + 1))
    done
    if pgrep -x "$name" &>/dev/null; then
        killall -9 "$name" 2>/dev/null || true
        sleep 0.3
    fi
}

switch_theme() {
    local theme="$1"
    local theme_file

    theme_file=$(readlink -f "$THEME_DIR/$theme")
    if [[ ! -f "$theme_file" ]]; then
        notify_user "主题 $theme 不存在" 2000
        return 1
    fi

    log_info "Switching to theme: $theme"

    echo "$theme" > "$HOME/.config/theme"

    if pgrep -x fcitx5 &>/dev/null; then
        fcitx5-remote -e 2>/dev/null || true
        sleep 0.3
        _graceful_kill fcitx5 3
    fi
    systemctl stop --user fcitx5-daemon 2>/dev/null || true

    if [[ -f "$HOME/.local/bin/generate-app-themes.py" ]]; then
        python3 "$HOME/.local/bin/generate-app-themes.py" "$theme_file" || {
            log_error "generate-app-themes.py failed"
            notify_user "错误: 生成应用配置失败" 3000
            return 1
        }
    fi

    dark_val=$(grep -m1 '^#define\s\+DARK_THEME\s\+[0-9]' "$theme_file" | awk '{print $3}')
    fcitx5_conf="$HOME/.config/fcitx5/conf/classicui.conf"
    if [[ -f "$fcitx5_conf" ]]; then
        if [[ "$dark_val" == "1" ]]; then
            sed -i 's/^Theme=.*/Theme=dwm-dark/' "$fcitx5_conf"
            sed -i 's/^DarkTheme=.*/DarkTheme=dwm-dark/' "$fcitx5_conf"
        else
            sed -i 's/^Theme=.*/Theme=dwm/' "$fcitx5_conf"
            sed -i 's/^DarkTheme=.*/DarkTheme=dwm/' "$fcitx5_conf"
        fi
    fi

    gtk_theme=$(grep -m1 '^#define\s\+GTK_THEME\s\+' "$theme_file" | sed 's/^#define\s\+GTK_THEME\s\+//')
    if [[ -n "$gtk_theme" ]] && ! validate_gtk_theme "$gtk_theme"; then
        log_warn "GTK theme '$gtk_theme' not found in standard paths"
        notify_user "警告: GTK 主题 '$gtk_theme' 未找到" 3000
    fi

    restart_xsettingsd

    xrdb -merge "$theme_file" || {
        log_error "xrdb -merge failed for $theme_file"
        notify_user "错误: xrdb 合并失败" 3000
        return 1
    }

    pkill -USR1 dwm 2>/dev/null || true

    _graceful_kill slstatus 2
    slstatus &
    disown

    _graceful_kill dunst 2
    dunst &
    disown

    if command -v kitty &>/dev/null; then
        kitty @ set-colors --all --configured "$HOME/.config/kitty/kitty.conf" &>/dev/null || true
    fi

    fcitx5 -d &
    disown

    update_lightdm_greeter

    notify_user "主题已切换: $theme" 2000
    log_info "Theme switched to: $theme"
}

main() {
    check_deps || exit 1

    local theme=""
    if [[ -n "${1:-}" ]]; then
        theme="$1"
    else
        theme=$(show_menu) || exit 0
    fi

    if [[ -n "$theme" ]]; then
        switch_theme "$theme"
    fi
}

main "$@"
