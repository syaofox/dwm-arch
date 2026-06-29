#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_ROOT/setup/utils.sh"

FAILED=()
SUCCESS=()

update_from_git() {
    local name="$1"
    local repo="$2"
    local build_dir="$3"
    local branch="${4:-}"

    log_step "检查更新: $name"

    if [[ ! -d "$build_dir" ]]; then
        log_info "目录不存在，执行首次安装..."
        if ! "$PROJECT_ROOT/setup/install-${name}.sh"; then
            FAILED+=("$name")
            return 1
        fi
        SUCCESS+=("$name")
        return 0
    fi

    pushd "$build_dir" > /dev/null

    local update_available=false
    if [[ -n "$branch" ]]; then
        git fetch origin --tags 2>/dev/null || true
        if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
            if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/$branch)" ]]; then
                update_available=true
            fi
        fi
    else
        git remote update 2>/dev/null || true
        if [[ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]]; then
            update_available=true
        fi
    fi

    if ! $update_available; then
        log_info "已是最新，跳过"
        SUCCESS+=("$name (no change)")
        popd > /dev/null
        return 0
    fi

    log_info "发现更新，重新编译安装..."
    if [[ -n "$branch" ]]; then
        git checkout -B "$branch" "origin/$branch"
    else
        git pull --ff-only
    fi

    make clean 2>/dev/null || true
    if sudo make install; then
        log_info "$name 更新成功"
        SUCCESS+=("$name")
    else
        log_error "$name 编译/安装失败"
        FAILED+=("$name")
        popd > /dev/null
        return 1
    fi
    popd > /dev/null
}

update_yay() {
    log_step "检查更新: yay"
    if command -v yay &>/dev/null; then
        if yay -Qua yay 2>/dev/null | grep -q yay; then
            log_info "发现 yay 更新，执行升级..."
            yay -S --noconfirm yay || {
                FAILED+=("yay")
                return 1
            }
            SUCCESS+=("yay")
        else
            log_info "已是最新，跳过"
            SUCCESS+=("yay (no change)")
        fi
    else
        log_info "yay 未安装，跳过"
    fi
}

update_mint_themes() {
    log_step "检查更新: mint-y-icons / mint-themes"
    if [[ -d "/usr/share/icons/Mint-Y" ]]; then
        log_info "从 GitHub 重新克隆安装..."
        if "$PROJECT_ROOT/setup/install-mint-themes.sh"; then
            SUCCESS+=("mint-themes")
        else
            FAILED+=("mint-themes")
        fi
    else
        log_info "Mint 主题未安装，跳过"
    fi
}

run_update() {
    echo ""
    echo "========================================"
    echo "      源码安装包更新工具"
    echo "========================================"
    echo ""

    update_from_git "dwm"      "https://github.com/syaofox/dwm.git"      "/tmp/dwm"
    update_from_git "slstatus" "https://github.com/syaofox/slstatus.git" "/tmp/slstatus"
    update_from_git "slock"    "https://github.com/syaofox/slock.git"    "/tmp/slock"
    update_from_git "wallpick" "https://github.com/syaofox/wallpick.git" "/tmp/wallpick"
    update_from_git "sysmenu"  "https://github.com/syaofox/sysmenu.git"  "/tmp/sysmenu"

    update_yay
    update_mint_themes

    echo ""
    echo "========================================"
    echo "              更新结果"
    echo "========================================"
    for pkg in "${SUCCESS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $pkg"
    done
    for pkg in "${FAILED[@]}"; do
        echo -e "  ${RED}✗${NC} $pkg"
    done
    echo "========================================"

    if [[ ${#FAILED[@]} -gt 0 ]]; then
        return 1
    fi
}

run_update "$@"
