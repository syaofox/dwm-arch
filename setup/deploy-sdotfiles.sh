#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

SDOTFILES_DIR="$PROJECT_ROOT/sdotfiles"
BACKUP_DIR="/etc/.config-backup-$(date +%Y%m%d-%H%M%S)"

BACKUP_DONE=0

sudo_backup_and_copy() {
    local src="$1"
    local target="$2"

    if sudo test -e "$target" || sudo test -L "$target"; then
        if [ $BACKUP_DONE -eq 0 ]; then
            sudo mkdir -p "$BACKUP_DIR"
            BACKUP_DONE=1
        fi
        local backup_path="$BACKUP_DIR${target}"
        local backup_dir="$(dirname "$backup_path")"
        sudo mkdir -p "$backup_dir"
        sudo mv "$target" "$backup_path"
        log_info "Backed up: $target -> $backup_path"
    fi

    local target_dir="$(dirname "$target")"
    if ! sudo test -d "$target_dir"; then
        sudo mkdir -p "$target_dir"
    fi

    sudo cp -fp "$src" "$target"
    log_info "Copied: $target"
}

log_step "Deploying system dotfiles (sudo required)..."

if [ ! -d "$SDOTFILES_DIR" ]; then
    log_error "System dotfiles directory not found: $SDOTFILES_DIR"
    exit 1
fi

if command -v systemctl &>/dev/null; then
    systemctl stop --user fcitx5-daemon 2>/dev/null || true
fi

while IFS= read -r rel_path; do
    rel_path="${rel_path#./}"
    [ -z "$rel_path" ] && continue

    src="$SDOTFILES_DIR/$rel_path"
    target="/$rel_path"

    sudo_backup_and_copy "$src" "$target"
    
done < <(cd "$SDOTFILES_DIR" && find . \( -type f -o -type l \) 2>/dev/null | grep -v '^./\.git$' | grep -v '^./\.svn$')

if command -v systemctl &>/dev/null && systemctl is-active --user fcitx5-daemon &>/dev/null; then
    systemctl restart --user fcitx5-daemon 2>/dev/null || true
else
    fcitx5 -d 2>/dev/null || true
fi

log_info "System dotfiles deployed successfully, refreshing font cache..."
sudo fc-cache -f
log_info "Font cache refreshed"
