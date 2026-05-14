#!/bin/bash
set -Eeuo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

CURRENT_USER=$(whoami)

log_step "Install LightDM display manager..."

log_info "Installing LightDM and GTK greeter..."
sudo pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter

log_info "Enabling LightDM service..."
sudo systemctl enable lightdm.service

log_info "Cleaning up old TTY autologin configuration..."

AUTOLOGIN_CONF="/etc/systemd/system/getty@tty1.service.d/autologin.conf"
if [[ -f "$AUTOLOGIN_CONF" ]]; then
    sudo rm -f "$AUTOLOGIN_CONF"
    log_info "Removed: $AUTOLOGIN_CONF"
fi

FISH_AUTOLOGIN="$HOME/.config/fish/conf.d/autologin.fish"
if [[ -f "$FISH_AUTOLOGIN" ]]; then
    rm -f "$FISH_AUTOLOGIN"
    log_info "Removed: $FISH_AUTOLOGIN"
fi

TTY_STARTX_SCRIPT="$HOME/.local/bin/tty-lock-and-startx.sh"
if [[ -f "$TTY_STARTX_SCRIPT" ]]; then
    rm -f "$TTY_STARTX_SCRIPT"
    log_info "Removed: $TTY_STARTX_SCRIPT"
fi

SUDOERS_FILE="/etc/sudoers.d/tty-lock-startx-$CURRENT_USER"
if [[ -f "$SUDOERS_FILE" ]]; then
    sudo rm -f "$SUDOERS_FILE"
    log_info "Removed sudoers rule: $SUDOERS_FILE"
fi

log_info "LightDM installation complete!"
log_info "After reboot, LightDM will start and you can log in to the dwm session."
