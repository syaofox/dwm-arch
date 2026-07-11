# NixOS Configuration — DWM Desktop

此目录包含完整的 NixOS flake + home-manager 配置，用于复刻 dwm-arch 桌面环境。

## 目录结构

```
nixos/
├── flake.nix                        # 入口：定义 inputs + outputs
├── hosts/
│   └── main/
│       ├── default.nix              # 主机配置（hostname、时区、locale）
│       └── hardware.nix             # 硬件配置（磁盘、bootloader）
├── modules/
│   ├── nixos/                       # 系统级 NixOS 模块
│   │   ├── default.nix              # 模块集合
│   │   ├── boot.nix                 # systemd-boot, 内核参数
│   │   ├── security.nix             # polkit, PAM (faillock 禁用)
│   │   ├── sysctl.nix               # fs.inotify.max_user_watches
│   │   ├── users.nix                # 用户 syaofox, 组, shell
│   │   ├── desktop/
│   │   │   ├── dwm.nix              # DWM 会话注册 + session wrapper
│   │   │   └── lightdm.nix          # LightDM GTK greeter
│   │   ├── hardware/
│   │   │   ├── nvidia.nix           # NVIDIA 驱动 (modesetting, power)
│   │   │   └── audio.nix            # PipeWire
│   │   ├── programs/
│   │   │   ├── fonts.nix            # 字体 + fontconfig (CJK fallback)
│   │   │   ├── fcitx5.nix           # 中文输入法
│   │   │   ├── docker.nix           # Docker daemon
│   │   │   └── nix.nix              # Nix 设置 (experimental-features, GC)
│   │   └── services/
│   │       └── zram.nix             # ZRAM swap (zstd, 50%)
│   └── home/                        # 用户级 home-manager 模块
│       ├── default.nix              # 模块集合
│       ├── core.nix                 # XDG, sessionVariables, 安装包
│       ├── scripts.nix              # dwmcmd.sh, switch-theme.sh 等脚本
│       ├── gtk.nix                  # GTK2/3/4 + Qt5/6 主题
│       ├── mime.nix                 # MIME 关联
│       ├── xresources.nix           # ~/.Xresources + theme files
│       ├── dwm/
│       │   ├── session.nix          # ~/.local/share/dwm/dwm-session.sh
│       │   └── autostart.nix        # ~/.local/share/dwm/autostart.sh
│       └── programs/
│           ├── git.nix, fish.nix, kitty.nix, neovim.nix
│           ├── rofi.nix, yazi.nix, nemo.nix
│           ├── dunst.nix, picom.nix, fcitx5.nix
├── overlays/
│   └── default.nix                  # dwm/slstatus/slock → syaofox fork
│                                    # + wallpick, sysmenu, generate-app-themes
├── pkgs/                            # 自定义 Nix 包
│   ├── wallpick/default.nix         # 壁纸选择器
│   ├── sysmenu/default.nix          # 系统菜单
│   └── generate-app-themes/default.nix  # 主题引擎 (Python)
├── themes/                          # 主题 Nix attrset 定义 (5 个)
│   ├── default.nix                  # 主题集合
│   ├── tokyonight.nix, dwm.nix, nord.nix
│   └── catppuccin-mocha.nix, mint-y-teal.nix
├── config/
│   ├── .Xresources                  # Xft 基础配置
│   ├── Xresources.d/                # 5 个主题文件 (tokyonight, dwm, 等)
│   └── theme-templates/             # Jinja2 模板目录 (见下方说明)
└── secrets/                         # agenix 加密密钥占位
```

## 前置条件

- NixOS 已安装，使用 `nixos-unstable` 频道或 flake 引导
- Nix 版本 ≥ 2.18（支持 `nix flake` 和 `nixos-rebuild flake`）
- 系统已启用 `experimental-features = nix-command flakes`
- Git 已安装

## 首次部署

### 1. 获取源码包 hash

所有从 `github.com/syaofox/*` 编译的包使用 `lib.fakeHash` 占位。首次构建时获取真实 hash：

```bash
cd /path/to/dwm-arch
nix build .#nixosConfigurations.main.config.system.build.toplevel
```

Nix 报错时复制实际 hash，依次更新：

| 文件 | 搜索 |
|---|---|
| `overlays/default.nix` | `hash = super.lib.fakeHash` → `hash = "sha256-..."` |
| `pkgs/wallpick/default.nix` | `hash = lib.fakeHash` → `hash = "sha256-..."` |
| `pkgs/sysmenu/default.nix` | `hash = lib.fakeHash` → `hash = "sha256-..."` |

### 2. 配置硬件

编辑 `hosts/main/hardware.nix`：

- 调整 `fileSystems` 中的磁盘设备路径
- 可选：添加 `nixos-hardware` 硬件配置（需在 flake.nix 中添加 input）

### 3. 准备主题模板（重要）

主题引擎 `generate-app-themes` **运行时依赖** Jinja2 模板文件，需要手动部署：

```bash
# 从现有 Arch 系统复制（如果已有）
cp -r ~/.config/theme-templates/* /path/to/dwm-arch/nixos/config/theme-templates/

# 或在首次启动后从备份恢复
mkdir -p ~/.config/theme-templates
# 然后手动放入模板文件
```

模板文件列表（从 `generate-app-themes.py` 的 `TEMPLATE_OUTPUTS` 可知）：
- dunstrc.j2, rofi.rasi.j2, yazi.toml.j2
- gtk2.j2, gtk3.ini.j2, gtk.css.j2, gtk-dark.css.j2
- qt5ct-colors.conf.j2, qt5ct-colors-dark.conf.j2
- qt5ct.conf.j2, qt6ct.conf.j2
- xsettingsd.conf.j2, kitty.conf.j2
- fcitx5.conf.j2, fcitx5-dark.conf.j2
- nvim.lua.j2

### 4. 部署配置

```bash
# 进入项目目录
cd /path/to/dwm-arch

# 语法检查
nix flake check

# 模拟激活（不实际应用）
nixos-rebuild dry-activate --flake .#main

# 首次部署（需要 root）
sudo nixos-rebuild switch --flake .#main

# 或仅部署用户配置（无需 root）
home-manager switch --flake .#syaofox@main
```

## 常用命令

```bash
# 构建但不切换
nixos-rebuild build --flake .#main

# 更新 flake.lock
nix flake update

# 仅更新某个 input
nix flake lock --update-input nixpkgs

# 回滚到上一代
nixos-rebuild switch --rollback

# 垃圾回收
sudo nix-collect-garbage -d
```

## 主题切换（运行时）

主题系统保持运行时切换能力（无需 `nixos-rebuild`）：

```bash
# 通过 rofi 选择主题（需要 X11 会话）
switch-theme

# 或直接指定主题名
switch-theme tokyonight
switch-theme nord
```

## 新增源码编译包

如果项目中新增了从源码编译的包（例如添加新的 `setup/install-*.sh`）：

1. 在 `pkgs/<name>/default.nix` 中创建 Nix 包
2. 在 `overlays/default.nix` 中添加 `package` 属性（用于 nixpkgs 已有）或 `callPackage`（用于自建）
3. 在 `modules/home/core.nix` 的 `home.packages` 中添加

## 已知限制

| 限制 | 说明 | 计划 |
|---|---|---|
| 主题模板 | `theme-templates/` 不由 Nix 管理，需手动部署 | 未来考虑纯 Nix 主题化 |
| 秘密管理 | `secrets/` 目录只有 `default.nix` 占位 | 按需配置 agenix |
| 硬件配置 | `hardware.nix` 需要用户根据实际硬件修改 | 各机自维护 |
| opencode | 未包含在 nixpkgs 中，需手动安装 | 可选 |
| VS Code | `vscode` 包可能需要 `programs.nix-ld.enable` | 按需启用 |
| Neovim | 插件通过 LazyVim 运行时管理 | 保持外部管理 |

## 排查

```bash
# 查看模块选项
nix eval .#nixosConfigurations.main.options.services.xserver.displayManager.session

# 查看系统包
nix eval .#nixosConfigurations.main.config.environment.systemPackages

# 构建详细日志
nix build -L .#nixosConfigurations.main.config.system.build.toplevel
```
