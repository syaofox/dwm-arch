#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing HuggingFace CLI (hf)..."

if command -v hf &> /dev/null && [[ "${FORCE_UPGRADE:-false}" != "true" ]]; then
    log_info "hf is already installed. Set FORCE_UPGRADE=true to reinstall/upgrade."
    exit 0
fi

log_info "Downloading and installing hf CLI..."
if ! curl -LsSf https://hf.co/cli/install.sh | bash -s; then
    log_error "Failed to install hf CLI"
    exit 1
fi

log_info "hf CLI installed successfully"
exit 0
