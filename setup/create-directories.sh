#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Creating common directories..."

user_dirs=(
    "$HOME/tmp"
    "$HOME/project"
)

mnt_dirs=(
    "/mnt/dnas/backup"
    "/mnt/dnas/data"
    "/mnt/dnas/download"
    "/mnt/dnas/wd12t"
    "/mnt/xiaoxin/data"
)

for dir in "${user_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_info "Created: $dir"
    else
        log_info "Already exists: $dir"
    fi
done

for dir in "${mnt_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir"
        sudo chown "$USER:$USER" "$dir"
        log_info "Created: $dir"
    else
        log_info "Already exists: $dir"
    fi
done
