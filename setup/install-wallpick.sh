#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Compile and install WallPick..."

compile_and_install "wallpick" "https://github.com/syaofox/wallpick.git" "/tmp/wallpick"
exit $?
