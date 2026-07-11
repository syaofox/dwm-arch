# AGENTS.md — dwm-arch

Arch Linux DWM dotfiles & provisioning repo.

# CRITICAL RULES - MUST FOLLOW

## RESPONSES

- Keep responses concise and to the point - unless the user asks otherwise

## PLANNING MODE

- Always ask clarifying questions
- Never assume design, tech stack or features
- Use deep-dive sub-agents to assist with research
- Use deep-dive sub-agents to review the different aspects of your plan before presenting to the user

## CHANGE / EDIT MODE

- Never implement features yourself when possible - use sub-agents!
- Identify changes from the plan that can be implemented in parallel, and use sub-agents to implement the features efficiently
- When using sub-agents to implement features, act as a coordinator only
- Use the best model for the task - premium models for complex tasks (like coding) and mid-tier models for simpler tasks, like documentation
- After completing features (large or small), always run commands like lint, type check and next build to check code quality

## 源码包更新

- 所有通过 `setup/install-*.sh` 脚本从源码编译安装的包，必须在 `tools/update-source-packages.sh` 中注册对应的更新函数
- 新增源码安装脚本时，同步在 `run_update()` 中添加调用

## NixOS 配置 (nixos/)

- `nixos/` 目录包含完整的 NixOS flake + home-manager 配置
- `nixos/pkgs/` — 自定义包 (wallpick, sysmenu, generate-app-themes)，通过 `nixos/overlays/` 注入 nixpkgs
- `nixos/overlays/` — 覆盖 dwm/slstatus/slock 源码指向 `github.com/syaofox/*`（初始 hash 为 `lib.fakeHash`，首次构建时替换为实际 hash）
- `nixos/modules/nixos/` — 系统级 NixOS 模块（boot, GPU, LightDM, 字体, Docker, ZRAM 等）
- `nixos/modules/home/` — 用户级 home-manager 模块（shell, terminal, editor, 脚本等）
- `nixos/themes/` — 5 个主题的 Nix attrset 定义（供未来纯 Nix 主题化使用）
- `nixos/config/Xresources.d/` — 从 `dotfiles/.Xresources.d/` 复制的静态主题文件
- `nixos/config/theme-templates/` — Jinja2 模板目录占位；**运行时依赖**：需手动将 `~/.config/theme-templates/` 复制至此
- `nixos/flake.nix` — 入口，输出 `nixosConfigurations.main` 和 `homeConfigurations."syaofox@main"`

### NixOS 配置约束

- 新增源码编译包时，需同步在 `nixos/pkgs/` 下创建 `callPackage`-able 派生式，并在 `nixos/overlays/default.nix` 中注册
- `nixos/` 内模块引用 `dotfiles/` 中的原配置文件（通过相对路径 `../../dotfiles/`），不要直接复制内容进 `nixos/`
- `nix flake check` 需要 Nix 2.18+；首次构建前需用 `nix build` 获取真实 hash，替换 `lib.fakeHash`

## 相关文档

- archlinux: https://wiki.archlinux.org/
- nixos: https://nixos.wiki/
- home-manager: https://nix-community.github.io/home-manager/

