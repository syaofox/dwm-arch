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

## 相关文档

- archlinux: https://wiki.archlinux.org/

