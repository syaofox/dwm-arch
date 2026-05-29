# conf.d/*.fish 由 fish 自动按文件名加载
# 模块拆分在 conf.d/ 目录下：
#   01-env.fish     环境变量
#   02-colors.fish  fish 颜色
#   03-aliases.fish 别名与缩写
#   04-fzf.fish     fzf 集成
#   05-yazi.fish    yazi 文件管理器
#   06-zoxide.fish  zoxide + thefuck

# 在 fish 4.x 中 theme 系统在 fish_prompt 事件中初始化颜色变量，
# 会覆盖 conf.d 中设置的值。用一次性事件在后面重新应用自定义颜色。
function _ensure_colors --on-event fish_prompt
    set --global fish_color_autosuggestion brblack
    functions --erase _ensure_colors
end
