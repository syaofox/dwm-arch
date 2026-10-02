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

## 日常同步

- 日常增量同步使用 `tools/update.sh`（`--dry-run` / `--only <repo相对路径>` / `--exclude <glob>` / `dotfiles|sdotfiles|all`），幂等且 `cp -p` 保权限，支持空格路径；全量仍可用 `setup/deploy-dotfiles.sh`
- `--exclude` 可重复传入，支持 `*` 通配与前缀式匹配（`X` 同时匹配 `X` 与 `X/` 下全部内容），路径写法与 `--only` 一致（带 `dotfiles/` 前缀）。用于跳过不该被仓库覆盖的本机路径
- 占位符：`bookmarks` 用 `__HOME__`，`qt5ct.conf` / `qt6ct.conf` 用 `@HOME@`，拷贝后由 `update.sh` 的 `sed` 替换为真实 `$HOME`。`files_are_identical()` 比较前会把 `$HOME` / `${HOME}` / `__HOME__` / `@HOME@` 统一归一化，因此这类文件不会每次误报漂移；归一化只在字节级 `cmp` 失败后才走，常规情况不增加开销
- 本机专属配置一律放仓库管辖不到的路径，例如 `~/.config/fish/conf.d/99-local.fish`（内含 `HF_TOKEN`，切勿入库）。同目录的 `01-env.fish` 由仓库同步管理，会被单向覆盖
- `tools/backup-secrets.sh` 管理敏感备份（原 `config-manager.sh` 已更名为此，保留兼容 shim）

## 主题相关文件的漂移是预期行为

以下文件由主题系统运行时改写，**仓库副本是历史快照，同步会覆盖当前主题状态**，因此不要"修复"这些漂移：

- `dotfiles/.config/kitty/theme.conf` —— 由 `~/.config/theme-templates/kitty.conf.j2` 经 `generate-app-themes.py` 生成
- `dotfiles/.config/fcitx5/conf/classicui.conf` 的 `Theme=` / `DarkTheme=` 两行 —— 由 `switch-theme.sh` 按当前主题明暗用 `sed -i` 改写（`dwm` / `dwm-dark`）

要改主题配色应改 `dotfiles/.config/theme-templates/*.j2`，而非这些生成结果。需要批量同步时用 `--exclude` 排除，例如：

```bash
tools/update.sh --exclude 'dotfiles/.config/kitty/theme.conf' \
                --exclude dotfiles/.config/fcitx5/conf/classicui.conf dotfiles
```

其余 `fcitx5/conf/*.conf` 与 `fcitx5/profile` 的漂移来自 fcitx5 首次运行时注释掉默认值，覆盖回模板等同重新初始化，可接受。

## OpenCode

- 配置为 V2，仓库仅收录两份文件：`dotfiles/.config/opencode/opencode.json`（server/项目配置，权限用 `permissions` 数组）与 `dotfiles/.config/opencode/cli.json`（TUI 专属，schema 为 `https://opencode.ai/v2/cli.json`）
- 权限写法为 V2 原生形式：`{action, resource, effect}` 三字段数组。V1 的 `permission` 对象映射、`bash`/`task` 动作名、`**` 通配符在 V2 下无效（通配符只有 `*` 与 `?`，`*` 已含 `/`）
- 浏览器插件 `@different-ai/opencode-browser` 处于停用状态：其为 V1 插件 API，与 V2 不兼容（V2 要求 default export 为带 `id` + `setup`/`effect` 的对象）。待其发布 V2 兼容版本后，重新在 `opencode.json` 的 `plugins` 中启用
- 安装方式：`setup/install-apps.sh` 优先官方 installer（`https://opencode.ai/v2/install`，装到 `~/.opencode/bin`），失败时回退 pacman `extra` 仓库的 `opencode` 包
- TUI 插件/依赖由 opencode 自行安装在 `~/.config/opencode/`（`package.json`、`node_modules` 等），不入库

## 相关文档

- archlinux: https://wiki.archlinux.org/

