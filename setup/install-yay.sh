#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


log_step "Installing yay AUR helper..."

# 检查 yay 是否已安装
if command -v yay &> /dev/null; then
    log_info "yay is already installed, skipping installation"
    exit 0
fi

# 检查是否以 root 运行
if [ "$EUID" -eq 0 ]; then
    log_error "Error: Do not run this script as root. Please run it as a regular user with sudo privileges."
    exit 1
fi

# 安装所需依赖
log_info "Installing dependencies..."
if ! pacman -Qi base-devel &> /dev/null; then
    log_info "Installing base-devel..."
    sudo pacman -S --noconfirm base-devel || exit 1
fi

if ! pacman -Qi git &> /dev/null; then
    log_info "Installing git..."
    sudo pacman -S --noconfirm git || exit 1
fi

# 创建临时构建目录
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

cd "$TEMP_DIR" || exit 1

# 克隆 yay 仓库
log_info "Cloning yay repository..."
git clone https://aur.archlinux.org/yay.git || exit 1
cd yay || exit 1

# 编译并安装 yay
log_info "Building yay..."
makepkg -si --noconfirm || exit 1

log_info "yay has been successfully installed!"
log_info "You can now use 'yay' to install packages from AUR"
exit 0