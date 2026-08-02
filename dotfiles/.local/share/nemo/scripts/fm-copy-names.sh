#!/bin/bash
# 复制选中文件/文件夹的名称到剪贴板（不包含路径）

# 收集选中的路径：优先使用 Nemo 脚本环境变量，回退到位置参数
# Nemo 行为：未选中时传入当前目录，需拒绝
FILES=()
if [ -n "${NEMO_SCRIPT_SELECTED_FILE_PATHS:-}" ]; then
    while IFS= read -r f; do
        [ -n "$f" ] && FILES+=("$f")
    done <<< "$NEMO_SCRIPT_SELECTED_FILE_PATHS"
elif [ $# -eq 1 ] && [ -d "$1" ]; then
    zenity --error --text="未选中任何文件，无法操作！"
    exit 1
else
    FILES=("$@")
fi

if [ "${#FILES[@]}" -eq 0 ]; then
    exit 0
fi

# 收集所有文件名，每行一个
NAMES=""

for path in "${FILES[@]}"; do
    [ -z "$path" ] && continue
    FILENAME=$(basename "$path")
    if [ -n "$NAMES" ]; then
        NAMES="$NAMES"$'\n'"$FILENAME"
    else
        NAMES="$FILENAME"
    fi
done

# 没有找到任何路径则退出
if [ -z "$NAMES" ]; then
    exit 0
fi

# 尝试使用 wl-clipboard (Wayland)
if command -v wl-copy &> /dev/null; then
    echo -n "$NAMES" | wl-copy
    exit 0
fi

# 尝试使用 xclip (X11)
if command -v xclip &> /dev/null; then
    echo -n "$NAMES" | xclip -selection clipboard
    exit 0
fi

# 如果都没有，尝试使用 xsel (X11 备选)
if command -v xsel &> /dev/null; then
    echo -n "$NAMES" | xsel --clipboard --input
    exit 0
fi

# 如果都没有安装，显示错误信息
zenity --error --text="未找到剪贴板工具！\n请安装 wl-clipboard (Wayland) 或 xclip/xsel (X11)"
exit 1
