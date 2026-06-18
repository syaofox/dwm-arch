set fish_greeting
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx HF_ENDPOINT https://hf-mirror.com
set -gx UV_CACHE_DIR "/mnt/github/.caches/uv"
set -gx BAT_THEME "Nord"
set -gx NVM_DIR "$HOME/.config/nvm"

# 设置 Android SDK 根目录
set -gx ANDROID_HOME $HOME/Android/Sdk

# 批量将 Android 工具链加入 PATH
# Fish 允许直接向 $PATH 追加一个列表
set -g fish_user_paths $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools $ANDROID_HOME/cmdline-tools/latest/bin $fish_user_paths

if test -f ~/.fzf/shell/key-bindings.fish
    source ~/.fzf/shell/key-bindings.fish
end

fish_add_path "$HOME/.local/bin"
if test -d $HOME/.opencode/bin
    fish_add_path $HOME/.opencode/bin
end
