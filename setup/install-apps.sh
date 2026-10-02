#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing user applications..."

PACMAN_packages=(
    # 编辑器与终端
    neovim
    kitty

    # 系统监视
    fastfetch
    htop
    nvtop

    # 媒体
    mpv
    gthumb
    pavucontrol

    # 桌面工具
    rofi
    nwg-look
    zenity
    maim
    calcurse
    pasystray
    chromium

    # 终端工具
    fzf fd ripgrep zoxide bat thefuck trash-cli

    # 开发工具
    nodejs npm
    uv
    lazygit
    code

    # 其他
    timeshift
    qalculate-gtk

    uget aria2
)

log_info "Installing official packages..."
if ! sudo pacman -S --needed --noconfirm "${PACMAN_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi

# ---------- opencode ----------
# 优先官方 installer (V2 最新版), 安装到 ~/.opencode/bin
# 该路径已由 dotfiles/.config/fish/conf.d/01-env.fish 加入 PATH
# 官方 installer 无法下载/执行时, 回退到 Arch 官方仓库的 opencode 包 (兜底, 版本可能略旧)
# 注意: installer 会向 ~/.config/fish/config.fish 追加一行 PATH (与 conf.d/01-env.fish 重复)。
# 本脚本在 install.sh 中先于 deploy-dotfiles.sh 执行, 该行会被 dotfile 覆盖, 故无需处理;
# 若调整 install.sh 顺序, 需注意此处会产生本地漂移。
log_step "Installing opencode..."

OPENCODE_INSTALLER_URL="https://opencode.ai/v2/install"
opencode_source=""

if command -v curl >/dev/null 2>&1 && curl -fsSL "$OPENCODE_INSTALLER_URL" | bash; then
    opencode_source="official installer"
else
    log_warn "Official installer unavailable, falling back to pacman..."
    if sudo pacman -S --needed --noconfirm opencode; then
        opencode_source="pacman (extra)"
    else
        log_error "Failed to install opencode (both installer and pacman failed)"
        exit 1
    fi
fi

# installer 装到 ~/.opencode/bin, 非 fish 环境或新开终端前需临时补进 PATH 才能校验
PATH="$HOME/.opencode/bin:$PATH"
export PATH

if command -v opencode >/dev/null 2>&1; then
    log_info "opencode installed via ${opencode_source}: $(opencode --version 2>/dev/null || echo 'version unknown')"
else
    log_warn "opencode not found in PATH; ensure ~/.opencode/bin is on PATH (see .config/fish/conf.d/01-env.fish)"
fi

log_info "User applications installation complete"
exit 0
