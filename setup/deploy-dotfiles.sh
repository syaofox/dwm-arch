#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

DOTFILES_DIR="$PROJECT_ROOT/dotfiles"
USER_HOME="$HOME"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

BACKUP_DONE=0

backup_and_copy() {
    local src="$1"
    local target="$2"

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ $BACKUP_DONE -eq 0 ]; then
            mkdir -p "$BACKUP_DIR"
            BACKUP_DONE=1
        fi
        local backup_path="$BACKUP_DIR/${target#$USER_HOME/}"
        local backup_dir="$(dirname "$backup_path")"
        mkdir -p "$backup_dir"
        mv "$target" "$backup_path"
        log_info "Backed up: $target -> $backup_path"
    fi

    local target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    cp -f "$src" "$target"
    log_info "Copied: $target"
}

log_step "Deploying dotfiles..."

if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

while IFS= read -r rel_path; do
    rel_path="${rel_path#./}"
    [ -z "$rel_path" ] && continue

    src="$DOTFILES_DIR/$rel_path"
    target="$USER_HOME/$rel_path"

    backup_and_copy "$src" "$target"
done < <(cd "$DOTFILES_DIR" && find . \( -type f -o -type l \) 2>/dev/null | grep -v '^./\.git$' | grep -v '^./\.svn$')

log_info "Dotfiles deployed successfully"

log_step "Registering MIME associations..."

# 图片 → gthumb（覆盖浏览器自注册）
for mime in image/jpeg image/png image/gif image/bmp image/webp image/tiff image/svg+xml image/avif image/heic image/heif image/vnd.microsoft.icon; do
    xdg-mime default org.gnome.gThumb.desktop "$mime" 2>/dev/null || true
done

# 文本/代码 → VS Code
for mime in text/plain text/html text/markdown text/x-shellscript text/x-python text/x-json application/json text/x-lua text/x-yaml application/x-yaml text/x-toml application/toml text/javascript application/javascript text/x-typescript text/x-go text/x-rust text/x-csrc text/x-chdr text/x-c++src text/x-c++hdr text/css text/x-diff application/x-httpd-php application/xml text/xml; do
    xdg-mime default code-oss.desktop "$mime" 2>/dev/null || true
done

# 媒体 → mpv
xdg-mime default mpv.desktop video/* 2>/dev/null || true
xdg-mime default mpv.desktop audio/* 2>/dev/null || true

# PDF → chromium
xdg-mime default chromium.desktop application/pdf 2>/dev/null || true

log_info "MIME associations registered"
