#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Mint themes and icons..."

BUILD_DIR="/tmp/mint-themes-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

log_info "Cloning mint-y-icons..."
git clone --depth 1 https://github.com/linuxmint/mint-y-icons.git "$BUILD_DIR/mint-y-icons"

log_info "Installing Mint-Y icons..."
sudo cp -r --preserve=mode "$BUILD_DIR/mint-y-icons/usr/share/icons/"* "/usr/share/icons/"
for theme in "$BUILD_DIR/mint-y-icons/usr/share/icons/"*; do
    name=$(basename "$theme")
    sudo gtk-update-icon-cache -f "/usr/share/icons/$name" 2>/dev/null || true
done
log_info "Mint-Y icons installed"

log_info "Cloning mint-themes..."
git clone --depth 1 https://github.com/linuxmint/mint-themes.git "$BUILD_DIR/mint-themes"

log_info "Building themes..."
cd "$BUILD_DIR/mint-themes"
python3 ./generate-themes.py 2>/dev/null

log_info "Installing Mint themes..."
sudo cp -r --preserve=mode "$BUILD_DIR/mint-themes/usr/share/themes/"* "/usr/share/themes/" 2>/dev/null || \
sudo cp -r --preserve=mode "$BUILD_DIR/mint-themes/files/usr/share/themes/"* "/usr/share/themes/"

rm -rf "$BUILD_DIR"

log_info "Mint themes installation complete"
exit 0
