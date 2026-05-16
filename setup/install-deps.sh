#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing system dependencies..."

PACMAN_packages=(
    # X11 桌面基础
    base-devel
    libx11 libxft libxinerama libxrandr
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xorg-xset xorg-xrdb
    xdotool dbus libnotify

    # 版本控制与系统工具
    git
    xsettingsd
    curl wget vim vi nano
    bash-completion
    rsync udisks2 udiskie
    btrfs-progs

    # 通知、网络、认证
    dunst
    network-manager-applet
    polkit-gnome
    numlockx
    blueman

    # 显示与输入
    xss-lock
    xclip xfce4-clipman-plugin
    xwallpaper
    picom
    xdg-user-dirs
    dconf

    # 文件系统与挂载
    gvfs
    mtools smbclient cifs-utils nfs-utils
    fuse3

    # 桌面门户
    qt5ct
    qt6ct
    xdg-desktop-portal xdg-desktop-portal-gtk

    # 归档
    unzip 7zip

    # 其他
    jq
    gnome-keyring
)

log_info "Installing official packages..."
if ! sudo pacman -S --needed --noconfirm "${PACMAN_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi

log_info "System dependencies installation complete"
exit 0
