#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Compile and install sysmenu..."

compile_and_install "sysmenu" "https://github.com/syaofox/sysmenu.git" "/tmp/sysmenu"
exit $?
