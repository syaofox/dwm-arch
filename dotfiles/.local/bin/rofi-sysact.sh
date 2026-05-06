#!/bin/bash
# 使用 dmenu/rofi 显示系统电源菜单

# # 关机/重启前尝试优雅卸载 NFS、CIFS 和 /media/ 下的外置盘
# pre_shutdown_cleanup() {
#     sync

#     {
#         findmnt -t nfs,nfs4,cifs,smb3 -o TARGET --noheadings 2>/dev/null
#         findmnt -l -o TARGET --noheadings 2>/dev/null | grep '^/media/'
#     } | sort -u | while IFS= read -r mnt; do
#         [ -z "$mnt" ] && continue
#         mountpoint -q "$mnt" || continue
#         if ! timeout 10 umount "$mnt" 2>/dev/null; then
#             timeout 5 umount -f -l "$mnt" 2>/dev/null || true
#         fi
#     done

#     sync
# }

# 定义选项
lock="  Lock"
reboot="  Reboot"
shutdown="  Shutdown"

# 根据安装情况选择菜单工具 (优先 rofi，其次 dmenu)
if command -v rofi &> /dev/null; then
    menu_cmd="rofi -dmenu -i -p System -theme theme"
else
    menu_cmd="dmenu -i -p System:"
fi

# 显示菜单
options="$lock\n$reboot\n$shutdown"
selected="$(echo -e "$options" | $menu_cmd)"

# 执行操作
case "$selected" in
    "$shutdown")
        # pre_shutdown_cleanup
        systemctl poweroff
        ;;
    "$reboot")
        # pre_shutdown_cleanup
        systemctl reboot
        ;;
    "$lock")
        slock
        ;;
esac

