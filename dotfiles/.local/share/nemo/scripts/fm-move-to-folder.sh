#!/bin/bash
# Nemo 行为：选中文件时传入文件路径，未选中时传入当前目录
if [ $# -eq 1 ] && [ -d "$1" ]; then
    zenity --error --text="未选中任何文件，无法操作！"
    exit 1
fi

BASE_DIR=$(dirname "$1")

NEW_NAME=$(zenity --entry --title="新建文件夹" --text="输入新文件夹名称:" --entry-text="New Folder")

if [ -z "$NEW_NAME" ]; then exit 0; fi

TARGET_DIR="$BASE_DIR/$NEW_NAME"

if [ -d "$TARGET_DIR" ]; then
    zenity --error --text="文件夹 \"$NEW_NAME\" 已存在！\n操作已取消。"
    exit 1
fi

mkdir -p "$TARGET_DIR"
for file in "$@"; do
    if [ -e "$file" ]; then
        mv "$file" "$TARGET_DIR/"
    fi
done

