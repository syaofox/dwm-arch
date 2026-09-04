#!/bin/bash
set -euo pipefail

# tools/update.sh — 增量同步入口 (dotfiles/sdotfiles)
# 用法: tools/update.sh [--dry-run] [--only <repo相对路径>] [dotfiles|sdotfiles|all]
# 特性: 幂等 (checksum 相同则跳过), cp -p / rsync -a 保权限 (+x), 支持空格路径, --dry-run 仅 diff

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(dirname -- "$SCRIPT_DIR")"

# 复用日志函数;若 utils.sh 不存在则回退到本地实现
if [[ -f "$PROJECT_ROOT/setup/utils.sh" ]]; then
    # shellcheck source=/dev/null
    source "$PROJECT_ROOT/setup/utils.sh"
else
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
    log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
    log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
    log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
    log_step()  { echo -e "\n${CYAN}==> $*${NC}"; }
fi

DOTFILES_DIR="$PROJECT_ROOT/dotfiles"
SDOTFILES_DIR="$PROJECT_ROOT/sdotfiles"
USER_HOME="$HOME"
DOTFILES_BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
SDOTFILES_BACKUP_DIR="/etc/.config-backup-$(date +%Y%m%d-%H%M%S)"

DOTFILES_BACKUP_DONE=0
SDOTFILES_BACKUP_DONE=0

DRY_RUN=false
ONLY_FILTER=""
MODE="all"

TOTAL_UPDATED=0
TOTAL_UNCHANGED=0
TOTAL_NEW=0

usage() {
    local exit_code="${1:-0}"
    cat <<EOF
Usage: ${0##*/} [--dry-run] [--only <repo相对路径>] [dotfiles|sdotfiles|all]

增量同步 dotfiles (用户级 \$HOME) 与 sdotfiles (系统级 /) 到本地,幂等且保权限.

Positional:
  dotfiles              仅同步 dotfiles  -> \$HOME
  sdotfiles             仅同步 sdotfiles -> / (需 sudo)
  all                   同步 dotfiles + sdotfiles (默认)

Options:
  --dry-run             仅展示 diff, 不实际拷贝/备份
                        dotfiles: diff -q / rsync --dry-run
                        sdotfiles: sudo rsync --dry-run
  --only <path>         仅同步单文件或单目录 (仓库相对路径)
                        例如: --only dotfiles/.local/share/nemo/scripts/fm-move-to-folder.sh
                              --only dotfiles/.config
                              --only sdotfiles/etc/fonts/local.conf
                              --only sdotfiles/etc
  -h, --help            显示此帮助并退出

Examples:
  ${0##*/}                              # 全量增量同步 (dotfiles+sdotfiles)
  ${0##*/} dotfiles                     # 仅用户级
  ${0##*/} --dry-run                    # 预览全量变更
  ${0##*/} --dry-run dotfiles           # 预览用户级变更
  ${0##*/} --only dotfiles/.config/nvim/init.lua
  ${0##*/} --dry-run --only dotfiles/.local/share/nemo/scripts/fm-move-to-folder.sh dotfiles
  ${0##*/} --only sdotfiles/etc/fonts/local.conf sdotfiles
  ${0##*/} --dry-run --only sdotfiles/etc sdotfiles

Backup:
  dotfiles  -> \$HOME/.config-backup-时间戳 (复用 deploy-dotfiles.sh 逻辑)
  sdotfiles -> /etc/.config-backup-时间戳 (需 sudo)

Copy:
  使用 cp -p (保 mode/ownership/timestamps, 保留 +x) 或 rsync -a, 仅当 checksum 不同时才备份+覆盖
EOF
    exit "$exit_code"
}

# ---------- 参数解析 (while case, 支持空格路径) ----------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --only)
            if [[ $# -lt 2 || -z "${2:-}" || "${2:-}" == -* ]]; then
                log_error "--only 需要一个参数 <repo相对路径>"
                usage 1
            fi
            ONLY_FILTER="$2"
            shift 2
            ;;
        --only=*)
            ONLY_FILTER="${1#*=}"
            if [[ -z "$ONLY_FILTER" ]]; then
                log_error "--only 需要一个非空路径"
                usage 1
            fi
            shift
            ;;
        -h|--help)
            usage 0
            ;;
        --)
            shift
            break
            ;;
        dotfiles|sdotfiles|all)
            MODE="$1"
            shift
            ;;
        -*)
            log_error "未知选项: $1"
            usage 1
            ;;
        *)
            log_error "未知参数: $1"
            usage 1
            ;;
    esac
done

# 规范化 ONLY_FILTER: 去掉前缀 ./ 与尾部 /
if [[ -n "$ONLY_FILTER" ]]; then
    ONLY_FILTER="${ONLY_FILTER#./}"
    ONLY_FILTER="${ONLY_FILTER%/}"
    # 去掉重复的斜杠
    # 若为绝对路径,尝试转为仓库相对路径
    if [[ "$ONLY_FILTER" == "$PROJECT_ROOT"/* ]]; then
        ONLY_FILTER="${ONLY_FILTER#"$PROJECT_ROOT"/}"
    fi
    # 自动校验: 若不存在则警告但不退出,后续匹配会显示 0 文件
    if [[ ! -e "$PROJECT_ROOT/$ONLY_FILTER" ]]; then
        log_warn "--only 指向的路径在仓库中不存在: $ONLY_FILTER"
    fi
fi

# ---------- 工具函数 ----------
matches_only_filter() {
    local type="$1"   # dotfiles | sdotfiles
    local rel="$2"    # 仓库内相对路径, 如 .config/nvim/init.lua 或 etc/fonts/local.conf
    if [[ -z "$ONLY_FILTER" ]]; then
        return 0
    fi
    local filter="$ONLY_FILTER"
    # 允许 --only dotfiles 或 --only sdotfiles 表示该类型全量
    if [[ "$filter" == "$type" ]]; then
        return 0
    fi
    local repo_path="${type}/${rel}"
    # 额外支持: 若用户传入的 filter 不含类型前缀 (如 .config/xxx), 按当前 type 匹配
    # 但规范要求带前缀,这里仅作兼容
    if [[ "$filter" == "$rel" ]]; then
        return 0
    fi
    if [[ "$repo_path" == "$filter" ]]; then
        return 0
    fi
    if [[ "$repo_path" == "$filter"/* ]]; then
        return 0
    fi
    return 1
}

files_are_identical() {
    local src="$1"
    local target="$2"
    # 目标不存在 -> 不相同
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return 1
    fi
    # 任一为符号链接: 比较链接目标;若均为链接且指向相同则视为相同,否则不同
    if [[ -L "$src" || -L "$target" ]]; then
        local src_link="" tgt_link=""
        [[ -L "$src" ]] && src_link="$(readlink "$src" 2>/dev/null || true)"
        [[ -L "$target" ]] && tgt_link="$(readlink "$target" 2>/dev/null || true)"
        if [[ -L "$src" && -L "$target" && "$src_link" == "$tgt_link" ]]; then
            return 0
        fi
        # 链接与普通文件混用视为不同; 链接内容不同亦视为不同
        return 1
    fi
    # 均为普通文件: 二进制比较 (等价于 checksum 比较,但更快)
    if cmp -s -- "$src" "$target" 2>/dev/null; then
        return 0
    fi
    return 1
}

# sdotfiles 目标可能需 sudo 访问;优先普通比较,失败则 sudo 比较
sfiles_are_identical() {
    local src="$1"
    local target="$2"
    if sudo test ! -e "$target" && sudo test ! -L "$target" 2>/dev/null; then
        return 1
    fi
    if [[ -L "$src" ]] || sudo test -L "$target" 2>/dev/null; then
        local src_link="" tgt_link=""
        [[ -L "$src" ]] && src_link="$(readlink "$src" 2>/dev/null || true)"
        if sudo test -L "$target" 2>/dev/null; then
            tgt_link="$(sudo readlink "$target" 2>/dev/null || true)"
        fi
        if [[ -L "$src" ]] && sudo test -L "$target" 2>/dev/null && [[ "$src_link" == "$tgt_link" ]]; then
            return 0
        fi
        return 1
    fi
    # 尝试 sudo cmp; 若无需 sudo 亦可
    if sudo cmp -s -- "$src" "$target" 2>/dev/null; then
        return 0
    fi
    if cmp -s -- "$src" "$target" 2>/dev/null; then
        return 0
    fi
    return 1
}

# dotfiles: 幂等备份+拷贝 (cp -p 保 +x)
backup_and_copy_dotfiles() {
    local src="$1"
    local target="$2"

    if files_are_identical "$src" "$target"; then
        log_info "Unchanged: $target"
        TOTAL_UNCHANGED=$((TOTAL_UNCHANGED+1))
        return 0
    fi

    local is_new=0
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        is_new=1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        if [[ $is_new -eq 1 ]]; then
            log_info "[DRY RUN] New: $target <- $src"
            # rsync dry-run 展示
            if command -v rsync &>/dev/null; then
                rsync -a --dry-run --out-format="[DRY RUN] %n" -- "$src" "$target" 2>&1 | sed 's/^/[DRY RUN] rsync: /' || true
            fi
        else
            log_info "[DRY RUN] Would update: $target <- $src"
            # diff -q 展示差异; rsync --dry-run 作为补充
            if diff -q -- "$src" "$target" &>/dev/null; then
                : # 不应到此,已由 files_are_identical 保证不同
            else
                diff -q -- "$src" "$target" 2>&1 | sed 's/^/[DRY RUN] diff: /' || true
                if command -v rsync &>/dev/null; then
                    rsync -a --dry-run --itemize-changes -- "$src" "$target" 2>&1 | sed 's/^/[DRY RUN] rsync: /' || true
                fi
            fi
        fi
        if [[ $is_new -eq 1 ]]; then TOTAL_NEW=$((TOTAL_NEW+1)); else TOTAL_UPDATED=$((TOTAL_UPDATED+1)); fi
        return 0
    fi

    # 真实执行: 备份旧文件
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ $DOTFILES_BACKUP_DONE -eq 0 ]]; then
            mkdir -p -- "$DOTFILES_BACKUP_DIR"
            DOTFILES_BACKUP_DONE=1
            log_info "Backup dir: $DOTFILES_BACKUP_DIR"
        fi
        local backup_path="$DOTFILES_BACKUP_DIR/${target#"$USER_HOME"/}"
        local backup_dir
        backup_dir="$(dirname -- "$backup_path")"
        mkdir -p -- "$backup_dir"
        mv -- "$target" "$backup_path"
        log_info "Backed up: $target -> $backup_path"
    fi

    local target_dir
    target_dir="$(dirname -- "$target")"
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p -- "$target_dir"
    fi

    # cp -p 保权限 (+x); 处理空格路径
    cp -p -- "$src" "$target"
    log_info "Copied: $target"
    if [[ $is_new -eq 1 ]]; then TOTAL_NEW=$((TOTAL_NEW+1)); else TOTAL_UPDATED=$((TOTAL_UPDATED+1)); fi
}

# sdotfiles: 幂等备份+拷贝 (sudo cp -p / rsync -a)
sudo_backup_and_copy() {
    local src="$1"
    local target="$2"

    if sfiles_are_identical "$src" "$target"; then
        log_info "Unchanged: $target"
        TOTAL_UNCHANGED=$((TOTAL_UNCHANGED+1))
        return 0
    fi

    local is_new=0
    if ! sudo test -e "$target" && ! sudo test -L "$target" 2>/dev/null; then
        is_new=1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        if [[ $is_new -eq 1 ]]; then
            log_info "[DRY RUN] New (sudo): $target <- $src"
            if command -v rsync &>/dev/null; then
                sudo rsync -a --dry-run --out-format="[DRY RUN] %n" -- "$src" "$target" 2>&1 | sed 's/^/[DRY RUN] rsync: /' || true
            fi
        else
            log_info "[DRY RUN] Would update (sudo): $target <- $src"
            # 优先 sudo diff -q, 回退到 sudo rsync
            if sudo diff -q -- "$src" "$target" &>/dev/null; then
                : # 意外
            else
                sudo diff -q -- "$src" "$target" 2>&1 | sed 's/^/[DRY RUN] diff: /' || true
                if command -v rsync &>/dev/null; then
                    sudo rsync -a --dry-run --itemize-changes -- "$src" "$target" 2>&1 | sed 's/^/[DRY RUN] rsync: /' || true
                fi
            fi
        fi
        if [[ $is_new -eq 1 ]]; then TOTAL_NEW=$((TOTAL_NEW+1)); else TOTAL_UPDATED=$((TOTAL_UPDATED+1)); fi
        return 0
    fi

    if sudo test -e "$target" || sudo test -L "$target" 2>/dev/null; then
        if [[ $SDOTFILES_BACKUP_DONE -eq 0 ]]; then
            sudo mkdir -p -- "$SDOTFILES_BACKUP_DIR"
            SDOTFILES_BACKUP_DONE=1
            log_info "Backup dir (sudo): $SDOTFILES_BACKUP_DIR"
        fi
        local backup_path="$SDOTFILES_BACKUP_DIR${target}"
        local backup_dir
        backup_dir="$(dirname -- "$backup_path")"
        sudo mkdir -p -- "$backup_dir"
        sudo mv -- "$target" "$backup_path"
        log_info "Backed up: $target -> $backup_path"
    fi

    local target_dir
    target_dir="$(dirname -- "$target")"
    if ! sudo test -d "$target_dir" 2>/dev/null; then
        sudo mkdir -p -- "$target_dir"
    fi

    # 优先 rsync -a, 回退 cp -p (均需 sudo, 保 +x)
    if command -v rsync &>/dev/null; then
        sudo rsync -a -- "$src" "$target"
    else
        sudo cp -p -- "$src" "$target"
    fi
    log_info "Copied (sudo): $target"
    if [[ $is_new -eq 1 ]]; then TOTAL_NEW=$((TOTAL_NEW+1)); else TOTAL_UPDATED=$((TOTAL_UPDATED+1)); fi
}

sync_dotfiles() {
    log_step "Syncing dotfiles (incremental) -> \$HOME ..."
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        return 1
    fi

    local found=0
    # 使用 -print0 + IFS read -d '' 处理空格路径; 过滤 .git/.svn
    while IFS= read -r -d '' src_abs; do
        # src_abs 为 DOTFILES_DIR 下的绝对路径
        local rel_path="${src_abs#"$DOTFILES_DIR"/}"
        [[ -z "$rel_path" ]] && continue
        # 过滤 .git / .svn (与 deploy-dotfiles.sh 保持一致)
        if [[ "$rel_path" == .git/* || "$rel_path" == .git ]]; then continue; fi
        if [[ "$rel_path" == .svn/* || "$rel_path" == .svn ]]; then continue; fi

        if ! matches_only_filter "dotfiles" "$rel_path"; then
            continue
        fi
        found=1
        local src="$src_abs"
        local target="$USER_HOME/$rel_path"
        backup_and_copy_dotfiles "$src" "$target"
    done < <(find "$DOTFILES_DIR" \( -type f -o -type l \) -print0 2>/dev/null)

    if [[ -n "$ONLY_FILTER" && $found -eq 0 ]]; then
        log_warn "No dotfiles matched --only filter: $ONLY_FILTER"
    fi

    # 仅在非 dry-run 且有实际变更时执行占位符替换 (与 deploy-dotfiles.sh 一致)
    if [[ "$DRY_RUN" == false ]]; then
        log_step "Substituting path placeholders..."
        # shellcheck disable=SC2016
        sed -i "s|__HOME__|$HOME|g" "$HOME/.config/gtk-3.0/bookmarks" 2>/dev/null || true
        sed -i "s|@HOME@|$HOME|g" "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
        sed -i "s|@HOME@|$HOME|g" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true
        log_info "Path placeholders substituted"
    else
        log_info "[DRY RUN] Skip placeholder substitution"
    fi
}

sync_sdotfiles() {
    log_step "Syncing sdotfiles (incremental, sudo) -> / ..."
    if [[ ! -d "$SDOTFILES_DIR" ]]; then
        log_error "System dotfiles directory not found: $SDOTFILES_DIR"
        return 1
    fi

    local found=0
    while IFS= read -r -d '' src_abs; do
        local rel_path="${src_abs#"$SDOTFILES_DIR"/}"
        [[ -z "$rel_path" ]] && continue
        if [[ "$rel_path" == .git || "$rel_path" == .git/* ]]; then continue; fi
        if [[ "$rel_path" == .svn || "$rel_path" == .svn/* ]]; then continue; fi

        if ! matches_only_filter "sdotfiles" "$rel_path"; then
            continue
        fi
        found=1
        local src="$src_abs"
        local target="/$rel_path"
        sudo_backup_and_copy "$src" "$target"
    done < <(find "$SDOTFILES_DIR" \( -type f -o -type l \) -print0 2>/dev/null)

    if [[ -n "$ONLY_FILTER" && $found -eq 0 ]]; then
        log_warn "No sdotfiles matched --only filter: $ONLY_FILTER"
    fi

    if [[ "$DRY_RUN" == false ]]; then
        log_info "Refreshing font cache (sudo)..."
        sudo fc-cache -f 2>/dev/null || log_warn "fc-cache failed"
        log_info "Font cache refreshed"
    else
        log_info "[DRY RUN] Skip fc-cache"
    fi
}

# ---------- 主流程 ----------
main() {
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "DRY RUN enabled - no files will be modified"
    fi

    if [[ -n "$ONLY_FILTER" ]]; then
        log_info "Filter --only: $ONLY_FILTER"
    fi
    log_info "Mode: $MODE"

    local rc=0
    case "$MODE" in
        dotfiles)
            sync_dotfiles || rc=1
            ;;
        sdotfiles)
            sync_sdotfiles || rc=1
            ;;
        all)
            sync_dotfiles || rc=1
            sync_sdotfiles || rc=1
            ;;
        *)
            log_error "Invalid mode: $MODE"
            usage 1
            ;;
    esac

    echo ""
    echo "========================================"
    echo "          Sync Summary"
    echo "========================================"
    echo "  Updated  : $TOTAL_UPDATED"
    echo "  New      : $TOTAL_NEW"
    echo "  Unchanged: $TOTAL_UNCHANGED"
    if [[ "$DRY_RUN" == true ]]; then
        echo "  (DRY RUN - no changes written)"
    else
        if [[ $DOTFILES_BACKUP_DONE -eq 1 ]]; then
            echo "  Backup (dotfiles) : $DOTFILES_BACKUP_DIR"
        fi
        if [[ $SDOTFILES_BACKUP_DONE -eq 1 ]]; then
            echo "  Backup (sdotfiles): $SDOTFILES_BACKUP_DIR"
        fi
        if [[ $DOTFILES_BACKUP_DONE -eq 0 && $SDOTFILES_BACKUP_DONE -eq 0 && $TOTAL_UPDATED -eq 0 && $TOTAL_NEW -eq 0 ]]; then
            echo "  No backups needed (all unchanged)"
        fi
    fi
    echo "========================================"

    return $rc
}

main "$@"
