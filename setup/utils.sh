#!/bin/bash

: "${FORCE_UPGRADE:=false}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "\n${CYAN}==> $1${NC}"; }

compile_and_install() {
    local name="$1"
    local repo_url="$2"
    local build_dir="$3"

    log_info "Compiling and installing ${name}..."

    if [[ -d "$build_dir" ]]; then
        if [[ -d "$build_dir/.git" ]]; then
            log_info "Directory exists, updating repository..."
            cd "$build_dir" || return 1
            git pull || return 1
        else
            log_info "Directory exists but not a git repository, re-cloning..."
            rm -rf "$build_dir"
            git clone "$repo_url" "$build_dir" || return 1
            cd "$build_dir" || return 1
        fi
    else
        git clone "$repo_url" "$build_dir" || return 1
        cd "$build_dir" || return 1
    fi

    make clean 2>/dev/null || true
    sudo make install || return 1
    cd - > /dev/null || true

    log_info "${name} installed successfully"
    return 0
}

create_symlink() {
    local src="$1"
    local target="$2"

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            local current_target
            current_target="$(readlink "$target")"
            if [ "$current_target" = "$src" ]; then
                return 0
            fi
        fi
        rm -rf "$target"
    fi

    local target_dir
    target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    ln -s "$src" "$target"
    log_info "Linked: $target -> $src"
}

