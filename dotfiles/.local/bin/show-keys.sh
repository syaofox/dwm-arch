#!/bin/bash

# DWM 快捷键帮助脚本
# 使用 rofi 显示分类快捷键列表

CATEGORIES="基础操作
窗口布局
标签操作
鼠标操作
系统操作"

show_category() {
    local cat="$1"
    local keys=""

    case "$cat" in
        "基础操作")
            keys="Super + Space              启动应用菜单 (rofi)
Super + Return             打开终端 (kitty)
Super + e                  打开文件管理器 (nemo)
Super + w                  打开浏览器 (Brave)
Super + s                  打开网站菜单 (rofi)
Super + a                  截图 (复制到剪贴板)
Super + Shift + a          截图 (保存到文件)
Super + Shift + w          切换壁纸
Super + v                  打开剪贴板管理器
Super + Shift + l          锁屏
Super + Shift + /          显示快捷键帮助
Super + Shift + q          退出 DWM"
            ;;
        "窗口布局")
            keys="Super + j                  聚焦下一个窗口
Super + k                  聚焦上一个窗口
Super + q                  关闭当前窗口
Super + Shift + space      切换窗口置顶
Super + z                  切换全屏
Super + n                  切换到下个布局
Super + Shift + i          增加主区域客户端数
Super + Shift + d          减少主区域客户端数
Super + ,                  减小主窗口区域
Super + .                  增大主窗口区域
Super + equal              增加窗口间隙
Super + Shift + equal      减少窗口间隙
Super + g                  切换间隙启用/禁用
Super + Shift + g          重置为默认间隙"
            ;;
        "标签操作")
            keys="Super + 1-9                切换到指定标签
Super + Ctrl + 1-9           切换显示指定标签
Super + Alt + 1-9            将窗口移动到指定标签
Super + Ctrl + Alt + 1-9     移动窗口并切换到该标签
Super + Tab                  切换到下一个标签
Super + Shift + Tab          切换到上一个标签"
            ;;
"鼠标操作")
            keys="Super + client left button        移动窗口
Super + client middle button      切换浮动/平铺
Super + client right button       调整窗口大小
Super + Shift + client left       交换窗口（带吸附）
Middle click(titlebar)            最大化/还原窗口
Middle click(client)              交换主窗口（Zoom）
Left click(tag)                   切换到该标签视图
Right click(tag)                  显示/隐藏当前窗口在该标签
Super + Left click(tag)           将窗口移动到该标签
Super + Right click(tag)          切换窗口在该标签的显示状态
Middle click(statusbar)           打开终端
Left click(layout symbol)         切换到下一种布局
Right click(layout symbol)        切换到上一种布局"
            ;;
        "系统操作")
            keys="Ctrl + Alt + Delete         电源菜单
Audio + Raise               增加音量
Audio + Lower               减少音量
Audio + Mute                静音/取消静音"
            ;;
    esac

    SELECTED=$(echo "$keys
← 返回" | rofi -dmenu -p "$cat" -i -theme theme -theme-str "window { width: 50%; height: 50%; }")

    [ "$SELECTED" = "← 返回" ] && return 0
}

while true; do
    CATEGORY=$(echo "$CATEGORIES" | rofi -dmenu -p "选择类别" -i -theme theme -theme-str "window { width: 30%; }")

    [ -z "$CATEGORY" ] && exit

    show_category "$CATEGORY"
done