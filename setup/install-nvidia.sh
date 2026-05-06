#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Nvidia drivers..."

if ! lspci | grep -i nvidia > /dev/null 2>&1; then
    log_info "No Nvidia GPU detected, skipping Nvidia driver installation"
    exit 0
fi

log_info "Nvidia GPU detected, installing drivers..."

# Install Nvidia packages
NVIDIA_PACKAGES=(
    nvidia-open-dkms
    dkms
    libva-nvidia-driver
    nvidia-utils
)

if ! sudo pacman -S --needed --noconfirm "${NVIDIA_PACKAGES[@]}"; then
    log_error "Failed to install Nvidia packages"
    exit 1
fi

# Install matching kernel headers for DKMS
log_info "Installing kernel headers for DKMS..."
DETECTED_HEADERS=()
for kernel_pkg in $(pacman -Q | awk '/^linux-?[0-9a-z]* /{print $1}'); do
    headers_pkg="${kernel_pkg}-headers"
    if pacman -Si "$headers_pkg" &>/dev/null; then
        if ! pacman -Q "$headers_pkg" &>/dev/null; then
            DETECTED_HEADERS+=("$headers_pkg")
        fi
    fi
done

if [[ ${#DETECTED_HEADERS[@]} -gt 0 ]]; then
    sudo pacman -S --needed --noconfirm "${DETECTED_HEADERS[@]}" || log_warn "Failed to install some kernel headers"
    log_info "Installed kernel headers: ${DETECTED_HEADERS[*]}"
else
    log_info "Kernel headers already installed or none needed"
fi

# Configure modprobe.d for Nvidia DRM
log_info "Configuring modprobe for Nvidia DRM..."
MODPROBE_FILE="/etc/modprobe.d/nvidia.conf"
if [ ! -f "$MODPROBE_FILE" ]; then
    cat << 'EOF' | sudo tee "$MODPROBE_FILE" > /dev/null
# Nvidia DRM kernel module settings
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
# Preserve video memory across suspend/resume
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF
    log_info "Created $MODPROBE_FILE"
else
    log_info "$MODPROBE_FILE already exists"
fi

# Add kernel parameters to GRUB (if GRUB is used)
if command -v grub-mkconfig &>/dev/null && [ -f /boot/grub/grub.cfg ]; then
    log_info "GRUB detected, adding Nvidia kernel parameters..."
    GRUB_FILE="/etc/default/grub"
    if ! grep -q "nvidia_drm.modeset=1" "$GRUB_FILE"; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1"/' "$GRUB_FILE"
        log_info "Added nvidia_drm.modeset=1 to GRUB_CMDLINE_LINUX_DEFAULT"
    else
        log_info "nvidia_drm.modeset=1 already in GRUB_CMDLINE_LINUX_DEFAULT"
    fi
    if ! grep -q "nvidia_drm.fbdev=1" "$GRUB_FILE"; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.fbdev=1"/' "$GRUB_FILE"
        log_info "Added nvidia_drm.fbdev=1 to GRUB_CMDLINE_LINUX_DEFAULT"
    else
        log_info "nvidia_drm.fbdev=1 already in GRUB_CMDLINE_LINUX_DEFAULT"
    fi
    log_info "Regenerating GRUB config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
elif command -v bootctl &>/dev/null && [ -d /boot/loader ]; then
    log_info "systemd-boot detected, add 'nvidia_drm.modeset=1 nvidia_drm.fbdev=1' manually to your boot entry"
    log_info "Alternatively, add to /etc/kernel/cmdline if using unified kernel images"
else
    log_warn "No supported bootloader detected. Add 'nvidia_drm.modeset=1 nvidia_drm.fbdev=1' to your kernel parameters manually."
fi

# Blacklist nouveau driver
log_info "Blacklisting nouveau driver..."
NOUVEAU_BLACKLIST="/etc/modprobe.d/nouveau_blacklist.conf"
if [ ! -f "$NOUVEAU_BLACKLIST" ]; then
    cat << 'EOF' | sudo tee "$NOUVEAU_BLACKLIST" > /dev/null
# Blacklist the open-source nouveau driver for proprietary Nvidia driver
blacklist nouveau
options nouveau modeset=0
EOF
    log_info "Created $NOUVEAU_BLACKLIST"
else
    log_info "$NOUVEAU_BLACKLIST already exists"
fi

# Enable Nvidia systemd services
log_info "Enabling Nvidia systemd services..."
for svc in nvidia-powerd nvidia-suspend nvidia-hibernate nvidia-resume; do
    if systemctl list-unit-files "$svc.service" &>/dev/null; then
        sudo systemctl enable "$svc" 2>/dev/null && log_info "Enabled $svc" || log_warn "Failed to enable $svc"
    fi
done

log_info "Nvidia drivers installation complete"
exit 0
