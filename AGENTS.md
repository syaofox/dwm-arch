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

- 日常增量同步使用 `tools/update.sh`（`--dry-run` / `--only <repo相对路径>` / `dotfiles|sdotfiles|all`），幂等且 `cp -p` 保权限，支持空格路径；全量仍可用 `setup/deploy-dotfiles.sh`
- `tools/backup-secrets.sh` 管理敏感备份（原 `config-manager.sh` 已更名为此，保留兼容 shim）

## OpenCode

- 配置为 V2，仓库仅收录两份文件：`dotfiles/.config/opencode/opencode.json`（server/项目配置，权限用 `permissions` 数组）与 `dotfiles/.config/opencode/cli.json`（TUI 专属，schema 为 `https://opencode.ai/v2/cli.json`）
- 权限写法为 V2 原生形式：`{action, resource, effect}` 三字段数组。V1 的 `permission` 对象映射、`bash`/`task` 动作名、`**` 通配符在 V2 下无效（通配符只有 `*` 与 `?`，`*` 已含 `/`）
- 浏览器插件 `@different-ai/opencode-browser` 处于停用状态：其为 V1 插件 API，与 V2 不兼容（V2 要求 default export 为带 `id` + `setup`/`effect` 的对象）。待其发布 V2 兼容版本后，重新在 `opencode.json` 的 `plugins` 中启用
- 安装方式：`setup/install-apps.sh` 优先官方 installer（`https://opencode.ai/v2/install`，装到 `~/.opencode/bin`），失败时回退 pacman `extra` 仓库的 `opencode` 包
- TUI 插件/依赖由 opencode 自行安装在 `~/.config/opencode/`（`package.json`、`node_modules` 等），不入库

## 相关文档

- archlinux: https://wiki.archlinux.org/

