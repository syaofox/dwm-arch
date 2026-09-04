#!/bin/bash
# Nemo 行为：选中文件时传入文件路径，未选中时传入当前目录
set -u

FILES=()
if [ -n "${NEMO_SCRIPT_SELECTED_FILE_PATHS:-}" ]; then
    while IFS= read -r f; do
        [ -n "$f" ] && FILES+=("$f")
    done <<< "$NEMO_SCRIPT_SELECTED_FILE_PATHS"
else
    FILES=("$@")
fi

if [ "${#FILES[@]}" -eq 0 ]; then
    zenity --error --text="未选中任何文件，无法操作！"
    exit 1
fi

BASE_DIR=$(dirname "${FILES[0]}")

NEW_NAME=$(zenity --entry --title="新建文件夹" --text="输入新文件夹名称:" --entry-text="New Folder")
NEW_NAME="${NEW_NAME#"${NEW_NAME%%[![:space:]]*}"}"
NEW_NAME="${NEW_NAME%"${NEW_NAME##*[![:space:]]}"}"
if [ -z "$NEW_NAME" ]; then exit 0; fi

case "$NEW_NAME" in
    */*|.|..)
        zenity --error --text="文件夹名称无效！\n不能包含 \"/\"，且不能为 \".\" 或 \"..\"。"
        exit 1
        ;;
esac

TARGET_DIR="$BASE_DIR/$NEW_NAME"

if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
    zenity --error --text="文件夹 \"$NEW_NAME\" 已存在！\n操作已取消。"
    exit 1
fi

for f in "${FILES[@]}"; do
    if [ "$(dirname "$f")" != "$BASE_DIR" ]; then
        if ! zenity --question --text="所选文件来自多个目录，\n将全部移动到：\n$TARGET_DIR\n\n是否继续？"; then
            exit 0
        fi
        break
    fi
done

declare -A SEEN
for f in "${FILES[@]}"; do
    b=$(basename "$f")
    if [ -n "${SEEN[$b]+x}" ]; then
        zenity --error --text="所选文件中存在同名文件：\"$b\"\n无法全部移入同一文件夹，操作已取消。"
        exit 1
    fi
    SEEN[$b]=1
done

if ! mkdir -p "$TARGET_DIR"; then
    zenity --error --text="创建文件夹 \"$TARGET_DIR\" 失败！\n请检查权限。"
    exit 1
fi

MOVED=()
FAILED=()
for f in "${FILES[@]}"; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    if mv -n "$f" "$TARGET_DIR/"; then
        MOVED+=("$f")
    else
        FAILED+=("$(basename "$f")")
    fi
done

if [ "${#FAILED[@]}" -gt 0 ]; then
    ROLLBACK_FAILED=()
    for f in "${MOVED[@]}"; do
        mv -n "$TARGET_DIR/$(basename "$f")" "$f" 2>/dev/null || ROLLBACK_FAILED+=("$(basename "$f")")
    done
    rmdir "$TARGET_DIR" 2>/dev/null
    TEXT="以下文件移动失败：\n$(printf '• %s\n' "${FAILED[@]}")"
    if [ "${#ROLLBACK_FAILED[@]}" -gt 0 ]; then
        TEXT="$TEXT\n以下文件回滚失败，仍保留在目标文件夹：\n$(printf '• %s\n' "${ROLLBACK_FAILED[@]}")"
    else
        TEXT="$TEXT\n已移动的文件已回滚，操作取消。"
    fi
    zenity --error --text="$TEXT"
    exit 1
fi

exit 0
