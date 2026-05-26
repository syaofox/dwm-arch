#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Lutris..."

if ! lspci | grep -i nvidia > /dev/null 2>&1; then
    log_info "No Nvidia GPU detected, skipping Nvidia-specific packages"
    exit 0
fi

log_info "Nvidia GPU detected, installing Lutris with Nvidia support..."

LUTRIS_PACKAGES=(
    lutris
    wine-staging
    giflib
    lib32-giflib
    lib32-gnutls
    lib32-vulkan-icd-loader
    lib32-nvidia-utils
)

if ! sudo pacman -S --needed --noconfirm "${LUTRIS_PACKAGES[@]}"; then
    log_error "Failed to install Lutris packages"
    exit 1
fi

log_info "Lutris installation complete"
exit 0
