if status is-interactive
    alias ls='ls --color=auto'
    alias ll='ls -alhF --time-style="+%m-%d %H:%M:%S"'
    alias la='ls -A'
    alias trash='trash-put -v'
    alias comfyup='cd /mnt/github/comfyui-docker; touch ./custom_nodes/.update; docker compose restart; cd -'
    alias lzd='lazydocker'
    alias lzg='lazygit'
    alias dcp='docker compose'
    alias myip='curl -s ifconfig.me'
    alias port='sudo ss -tulnp | grep'
    alias bat-theme='bat --list-themes | fzf --preview="bat --theme={} --color=always ~/.config/themes/switch-theme.sh"'
    alias cat='bat'
    alias vram='watch -n 1 nvidia-smi'
    alias ram='watch -n 1 free -h'


    abbr -a v  nvim
    abbr -a vi nvim
    abbr -a vim nvim
end
