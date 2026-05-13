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
    gpicview
    pavucontrol

    # 桌面工具
    rofi
    # lxappearance
    nwg-look
    zenity
    maim
    calcurse
    pasystray

    # 终端工具
    fzf fd ripgrep zoxide bat thefuck trash-cli

    # 开发工具
    nodejs npm
    uv
    lazygit

    # 备份
    timeshift
)

log_info "Installing official packages..."
if ! sudo pacman -S --needed --noconfirm "${PACMAN_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi

log_info "Installing AUR packages via yay..."
AUR_PACKAGES=(
    clipster
    opencode-bin
    visual-studio-code-bin
    brave-origin-nightly-bin
    mint-y-icons
    mint-themes
)
if command -v yay >/dev/null; then
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" || log_warn "Some AUR packages failed to install"
fi

log_info "User applications installation complete"
exit 0
