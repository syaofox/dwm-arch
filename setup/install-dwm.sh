#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Compile and install DWM..."

compile_and_install "dwm" "https://github.com/syaofox/dwm.git" "/tmp/dwm"
exit $?
