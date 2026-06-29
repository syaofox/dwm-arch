#!/bin/bash
# 使用 cropgui 裁切图片
# 用法: fm-crop-image.sh <文件1> [文件2] ...

if [ $# -lt 1 ]; then
    zenity --error --text="请选择至少一张图片！"
    exit 1
fi

for image in "$@"; do
    gthumb "$image"
done

exit 0
