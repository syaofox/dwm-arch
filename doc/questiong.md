## 任务目标
[需求]

## 项目背景
- Arch Linux DWM dotfiles & provisioning repo。
- **项目类型**：桌面环境配置 + 系统初始化脚本 + 源码编译安装。
- **核心组件**：DWM (窗口管理器)、slstatus (状态栏)、slock (锁屏)、wallpick (壁纸)、sysmenu (启动器) — 均从源码编译。
- **项目结构**：
  - `setup/install-*.sh` — 独立安装脚本，由 `install.sh` 串行编排
  - `dotfiles/` — 用户级配置 (~/)，含 20+ 应用 (kitty, nvim, rofi, yazi 等)
  - `sdotfiles/` — 系统级配置 (/etc/, /usr/)
  - `tools/` — 辅助实用工具（配置管理、源码包更新）
  - `backups/` — 加密备份归档

## 可用资源
1. **知识图谱 MCP** (codebase-memory-mcp) — 优先用于搜索代码关系、追踪调用链，替代 grep/glob
2. **Bash 防御性编程技能** — 编写/修改 shell 脚本时加载 `bash-defensive-patterns` skill
3. **AGENTS.md 硬约束** — 所有源码编译安装脚本必须在 `tools/update-source-packages.sh` 中注册 `run_update()`
4. **浏览器自动化** — 分析源站参考时可用

## 执行约束
1. **沟通语言**：中文。
2. **前置评估**（回答 3 个问题后再提交方案）：
   - 影响范围？有无副作用？
   - 最优解？替代方案利弊？
   - 验证计划？（涉及安装脚本需说明幂等性及验证方式）
3. **确认拦截**：方案需经我确认，方可实施编码。
4. **后置处理**：修改完成后，检查并更新：
   - `AGENTS.md`（只针对 AI 无法从源码和知识图推断的硬约束）
   - `tools/update-source-packages.sh`（若新增或修改了源码编译脚本）
5. **不确定时**：务必追问，禁止猜测。
