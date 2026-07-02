#!/bin/bash
set -Eeuo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/setup/utils.sh"

[[ $EUID -eq 0 ]] && { echo "ERROR: Do not run this script as root. Use a regular user with sudo privileges." >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 询问用户失败后如何处理
ask_on_failure() {
    local step_name="$1"
    log_error "${step_name} failed"
    echo ""
    log_info "What would you like to do?"
    echo "  [r] Retry this step"
    echo "  [s] Skip this step"
    echo "  [e] Exit installation"
    echo ""
    read -p "Enter your choice [r/s/e]: " choice

    case $choice in
        r|R) return 1 ;;
        s|S) log_info "Skipping: ${step_name}"; echo ""; return 0 ;;
        e|E) log_info "Exiting installation..."; exit 1 ;;
        *) echo "Invalid choice. Please try again."; ask_on_failure "$step_name" ;;
    esac
}

# 带错误处理的步骤执行函数
run_step() {
    local step_name="$1"
    shift

    while true; do
        log_info "Running: ${step_name}..."
        if ("$@"); then
            log_info "${step_name} completed successfully!"
            echo ""
            return 0
        else
            ask_on_failure "$step_name" || continue
            return 0
        fi
    done
}


run_step "Upgrade system dependencies" "./setup/upgrade-system.sh"
run_step "Configure system locale" "./setup/configure-locale.sh"
run_step "Create common directories" "./setup/create-directories.sh"
run_step "Install AUR helper" "./setup/install-yay.sh"
run_step "Configure AUR build threads" "./setup/configure-makepkg.sh"
run_step "Install system dependencies" "./setup/install-deps.sh"

run_step "Compile and install DWM" "./setup/install-dwm.sh"
run_step "Compile and install slstatus" "./setup/install-slstatus.sh"
run_step "Compile and install slock" "./setup/install-slock.sh"
run_step "Compile and install wallpick" "./setup/install-wallpick.sh"
run_step "Compile and install sysmenu" "./setup/install-sysmenu.sh"

run_step "Install Mint themes and icons" "./setup/install-mint-themes.sh"
run_step "Install applications" "./setup/install-apps.sh"
run_step "Install yazi" "./setup/install-yazi.sh"
run_step "Install fonts" "./setup/install-fonts.sh"
run_step "Install Nemo files browser" "./setup/install-nemo.sh"
run_step "Install fcitx5" "./setup/install-fcitx5.sh"
run_step "Install fish shell" "./setup/install-fish.sh"


run_step "Install Nvidia drivers" "./setup/install-nvidia.sh"
# run_step "安装 Docker" "./setup/install-docker.sh"
# run_step "安装 KVM 虚拟化" "./setup/install-kvm.sh"

run_step "Install FLathub" "./setup/install-flathub.sh"
run_step "Deploy configuration files" "./setup/deploy-dotfiles.sh"
run_step "Deploy system configuration files" "./setup/deploy-sdotfiles.sh"
run_step "Update user groups" "./setup/update-usergroup.sh"

run_step "Install LightDM display manager" "./setup/install-lightdm.sh"







echo ""
log_info "═══════════════════════════════════════"
log_info "✓ All installation steps completed!"
log_info "═══════════════════════════════════════"
echo ""
log_info "Please reboot your system to apply all changes."

