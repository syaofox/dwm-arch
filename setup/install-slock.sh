#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Compile and install slock..."

compile_and_install "slock" "https://github.com/syaofox/slock.git" "/tmp/slock" "arch"
exit $?
