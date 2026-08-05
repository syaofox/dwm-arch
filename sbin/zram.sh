#!/bin/bash
# ZRAM 交换空间优化脚本（Arch Linux / 通用）
# 版本: 4.0
# 描述:
#   - 通过 systemd-zram-generator 配置 ZRAM 交换空间
# 用法:
#   ./zram.sh [百分比]              # 例如 ./zram.sh 50（默认: 75）
#   ./zram.sh [百分比] --chroot     # 仅写入配置，跳过服务管理
#   ./zram.sh --disable             # 关闭 ZRAM（移除配置并禁用服务）
# 验证脚本执行结果的方法
# 1. 检查 ZRAM 设备
# swapon --show
# 应看到 zram0 设备
# 2. 检查 ZRAM 配置
# cat /etc/systemd/zram-generator.conf
# 确认配置正确
# 3. 检查服务状态
# systemctl status systemd-zram-setup@zram0
# 确认服务已启用并运行

[[ "$(id -u)" -ne 0 ]] && exec sudo "$0" "$@"

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
log_step()  { echo -e "\n${CYAN}==> $1${NC}"; }

is_chroot() {
    [[ "${1:-}" == "--chroot" ]] && return 0
    [[ ! -d /run/systemd/system ]] && return 0
    return 1
}

run_zram_disable() {
    log_step "Disabling ZRAM"
    if [[ -f /etc/systemd/zram-generator.conf ]]; then
        BACKUP_DIR="/root/zram_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp -a /etc/systemd/zram-generator.conf "${BACKUP_DIR}/zram-generator.conf.bak"
        log_info "Config backed up to ${BACKUP_DIR}/zram-generator.conf.bak"
        rm -f /etc/systemd/zram-generator.conf
        log_info "Removed /etc/systemd/zram-generator.conf"
    else
        log_info "No /etc/systemd/zram-generator.conf found, skipping removal"
    fi

    local UNIT
    local UNITS
    UNITS=$(systemctl list-unit-files 'systemd-zram-setup@*' --no-legend --no-pager 2>/dev/null | awk '$1 !~ /^systemd-zram-setup@\.service$/ {print $1}')
    if [[ -d /run/systemd/system ]] && [[ -n "$UNITS" ]]; then
        for UNIT in $UNITS; do
            systemctl stop "$UNIT" 2>/dev/null || true
            systemctl disable "$UNIT" 2>/dev/null || true
            log_info "Stopped and disabled $UNIT"
        done
    else
        log_info "systemd not running or no zram service units found, service management skipped"
    fi

    local ZRAM_DEV
    for ZRAM_DEV in $(swapon --show=NAME --noheadings 2>/dev/null | grep '^/dev/zram' || true); do
        swapoff "$ZRAM_DEV" 2>/dev/null || true
        log_info "Swap off $ZRAM_DEV"
    done

    log_info "=========================================="
    log_info "ZRAM disabled"
    log_info "  - Config removed: /etc/systemd/zram-generator.conf"
    log_info "  - Service disabled: systemd-zram-setup@*.service"
    log_info "=========================================="
    log_warn "Reboot to fully unload zram modules"
}

run_zram_optimization() {
    local CHROOT_MODE=false
    local ZRAM_PERCENT=""

    for arg in "$@"; do
        case "$arg" in
            --disable)
                run_zram_disable
                return 0
                ;;
            --chroot) CHROOT_MODE=true ;;
            *)
                if [[ -z "$ZRAM_PERCENT" ]]; then
                    ZRAM_PERCENT="$arg"
                fi
                ;;
        esac
    done
    $CHROOT_MODE || { is_chroot "$@" && CHROOT_MODE=true || CHROOT_MODE=false; }

    ZRAM_PERCENT=${ZRAM_PERCENT:-75}

    if ! [[ "$ZRAM_PERCENT" =~ ^[0-9]+$ ]] || [ "$ZRAM_PERCENT" -lt 1 ] || [ "$ZRAM_PERCENT" -gt 100 ]; then
        log_error "Invalid percentage. Must be between 1 and 100"
    fi

    log_step "ZRAM Configuration (${ZRAM_PERCENT}% of RAM)"
    $CHROOT_MODE && log_info "Chroot mode: writing config only, service will start after reboot"

    BACKUP_DIR="/root/zram_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    if [[ -f /etc/systemd/zram-generator.conf ]]; then
        log_info "Existing config backed up to ${BACKUP_DIR}/zram-generator.conf.bak"
        cp -a /etc/systemd/zram-generator.conf "${BACKUP_DIR}/zram-generator.conf.bak"
    fi

    cat << EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 100 * ${ZRAM_PERCENT}
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

    log_info "Config written: /etc/systemd/zram-generator.conf"
    log_info "  zram-size = ram / 100 * ${ZRAM_PERCENT}  ($(awk '/MemTotal/ {printf "%.0f MB", $2/1024 * '"$ZRAM_PERCENT"'/100}' /proc/meminfo 2>/dev/null || echo "unknown"))"

    if ! $CHROOT_MODE; then
        systemctl daemon-reload 2>/dev/null || true
        systemctl enable systemd-zram-setup@zram0 2>/dev/null || true
        systemctl start systemd-zram-setup@zram0 2>/dev/null || true
        log_info "Service systemd-zram-setup@zram0 enabled and started"
    else
        log_info "Chroot mode: enable with 'systemctl enable systemd-zram-setup@zram0' after reboot"
    fi

    log_info "=========================================="
    log_info "ZRAM configured via systemd-zram-generator:"
    log_info "  - Size: ${ZRAM_PERCENT}% of RAM"
    log_info "  - Compression: zstd"
    log_info "  - Priority: 100"
    log_info "=========================================="
    log_info "Verify with: swapon --show"
    log_warn "Reboot or start systemd-zram-setup@zram0 to apply"
}

run_zram_optimization "$@"
