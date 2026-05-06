#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Compile and install slstatus..."

compile_and_install "slstatus" "https://github.com/syaofox/slstatus.git" "/tmp/slstatus"
exit $?
