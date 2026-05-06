if status is-interactive
    # 释放 Ctrl+S，否则被终端拦截为 XOFF 流控制
    stty -ixon

    set fzf_preview_dir_cmd exa --all --color=always
    set fzf_fd_opts --hidden --exclude=.git

    # 延迟到 fish_user_key_bindings 中执行绑定，确保不被默认绑定覆盖
    # 见 functions/fish_user_key_bindings.fish
end
