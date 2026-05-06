#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Configuring system locale..."

LOCALE="zh_CN.UTF-8"

if locale -a 2>/dev/null | grep -qi "${LOCALE,,}"; then
    log_info "Locale ${LOCALE} already generated, skipping"
    exit 0
fi

log_info "Uncommenting ${LOCALE} in /etc/locale.gen..."
sudo sed -i "/^#${LOCALE}/s/^#\+//" /etc/locale.gen

log_info "Generating locale..."
sudo locale-gen

log_info "Locale ${LOCALE} generated successfully"
exit 0
