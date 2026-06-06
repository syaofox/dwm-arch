#!/bin/bash
# 使用 cropgui 裁切图片
# 用法: fm-crop-image.sh <文件1> [文件2] ...

if [ $# -lt 1 ]; then
    zenity --error --text="请选择至少一张图片！"
    exit 1
fi

if ! command -v cropgui &> /dev/null; then
    zenity --error --text="未找到 cropgui！\n请先安装：\nsudo pacman -S cropgui\n或从 AUR 安装"
    exit 1
fi

for image in "$@"; do
    cropgui "$image"
done

exit 0
