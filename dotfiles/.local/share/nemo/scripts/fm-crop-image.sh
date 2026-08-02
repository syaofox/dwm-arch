#!/bin/bash
# 使用 gthumb 裁切图片
# 用法: fm-crop-image.sh <文件1> [文件2] ...

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
    zenity --error --text="请选择至少一张图片！"
    exit 1
fi

for image in "${FILES[@]}"; do
    gthumb "$image"
done

exit 0
