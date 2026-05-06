# Neovim 键位绑定文档

本文档简明扼要地列出了我的 Neovim 配置中的所有自定义键位绑定。

## 通用键位绑定

| 模式 | 键位            | 操作                                                                                      |
|------|-----------------|---------------------------------------------------------------------------------------------|
| `n`  | `<leader>cd`    | 打开 Ex 模式 (`:Ex`)                                                                        |
| `n`  | `J`             | 合并行并保持光标位置                                                |
| `n`  | `<C-d>`         | 向下滚动半页并保持光标居中                                          |
| `n`  | `<C-u>`         | 向上滚动半页并保持光标居中                                            |
| `n`  | `n`             | 跳转到下一个搜索结果并保持居中                                             |
| `n`  | `N`             | 跳转到上一个搜索结果并保持居中                                         |
| `n`  | `Q`             | 禁用 Ex 模式                                                                             |
| `n`  | `<C-k>`         | 跳转到下一个 quickfix 条目并保持居中                                            |
| `n`  | `<C-j>`         | 跳转到上一个 quickfix 条目并保持居中                                        |
| `n`  | `<leader>k`     | 跳转到下一个 location 条目并保持居中                                            |
| `n`  | `<leader>j`     | 跳转到上一个 location 条目并保持居中                                        |
| `i`  | `<C-c>`         | 退出插入模式（作用同 `Esc`）                                                          |
| `n`  | `<leader>x`     | 使当前文件可执行 (`chmod +x`)                                                   |
| `n`  | `<leader>u`     | 切换 Undotree                                                                             |
| `n`  | `<leader>rl`    | 重新加载 Neovim 配置 (`~/.config/nvim/init.lua`)                                        |
| `n`  | `<leader><leader>` | 重新加载当前文件 (`:so`)                                                          |

---

## 可视模式键位绑定

| 模式 | 键位            | 操作                                                                                      |
|------|-----------------|---------------------------------------------------------------------------------------------|
| `v`  | `J`             | 将选中块向下移动                                                                    |
| `v`  | `K`             | 将选中块向上移动                                                                      |
| `x`  | `<leader>p`     | 粘贴但不覆盖剪贴板                                                         |
| `v`  | `<leader>y`     | 复制到系统剪贴板（支持 SSH）                                                    |

---

## 代码检查与格式化

| 模式 | 键位            | 操作                                                                                      |
|------|-----------------|---------------------------------------------------------------------------------------------|
| `n`  | `<leader>cc`    | 运行 `php-cs-fixer` 检查和格式化 PHP 文件                                             |
| `n`  | `<F3>`          | 格式化代码（`LSP`）                                                                         |

---

## Telescope 键位绑定

| 模式 | 键位            | 操作                                                                                      |
|------|-----------------|---------------------------------------------------------------------------------------------|
| `n`  | `<leader>ff`    | 查找文件                                                                                  |
| `n`  | `<leader>fg`    | 查找 Git 跟踪的文件                                                                      |
| `n`  | `<leader>fo`    | 打开最近访问的文件                                                                           |
| `n`  | `<leader>fq`    | 打开 quickfix 列表                                                                          |
| `n`  | `<leader>fh`    | 打开帮助标签                                                                              |
| `n`  | `<leader>fb`    | 打开缓冲区列表                                                                            |
| `n`  | `<leader>fs`    | 搜索当前字符串                                                                         |
| `n`  | `<leader>fc`    | 搜索当前文件名（不含扩展名）的所有实例                               |
| `n`  | `<leader>fi`    | 在 Neovim 配置目录中查找文件 (`~/.config/nvim/`)                            |

---

## Harpoon 集成

| 模式 | 键位            | 操作                                                                                      |
|------|-----------------|---------------------------------------------------------------------------------------------|
| `n`  | `<leader>a`     | 将当前文件添加到 Harpoon 列表                                                            |
| `n`  | `<C-e>`         | 切换 Harpoon 快速菜单                                                                   |
| `n`  | `<leader>fl`    | 使用 Telescope 打开 Harpoon 窗口                                                          |
| `n`  | `<C-p>`         | 跳转到上一个 Harpoon 标记                                                                 |
| `n`  | `<C-n>`         | 跳转到下一个 Harpoon 标记                                                                 |

---

## LSP 键位绑定

| 模式      | 键位        | 操作                                                                                      |
|-----------|------------|---------------------------------------------------------------------------------------------|
| `n`       | `K`        | 显示悬停信息                                                                      |
| `n`       | `gd`       | 跳转到定义                                                                            |
| `n`       | `gD`       | 跳转到声明                                                                           |
| `n`       | `gi`       | 跳转到实现                                                                        |
| `n`       | `go`       | 跳转到类型定义                                                                       |
| `n`       | `gr`       | 显示引用                                                                             |
| `n`       | `gs`       | 显示签名帮助                                                                         |
| `n`       | `gl`       | 在浮动窗口中显示诊断信息                                                       |
| `n`       | `<F2>`     | 重命名符号                                                                               |
| `n`, `x`  | `<F3>`     | 异步格式化代码                                                                 |
| `n`       | `<F4>`     | 显示代码操作                                                                           |

---

## 其他

| 模式 | 键位            | 操作                                                                                      |
|------|-----------------|---------------------------------------------------------------------------------------------|
| `n`  | `<leader>dg`    | 运行 `DogeGenerate`（注释文档生成）                                       |
| `n`  | `<leader>s`     | 替换当前行中光标下的单词的所有实例                      |

---

# LSP 服务器：

我正在将 LSP 配置迁移到 /lua/plugins/lsp.lua，因为 nvim v0.11 支持一种极简的方式来设置语言服务器协议。

以下是本配置中将要配置的语言服务器及其安装方法的列表。我暂时避免使用 mason，因为我认为完全控制系统更好，而不是将其外包给 mason。如果你想采用这种方式，只需取消注释 /plugins/lsp.lua 中原始 lspconfig 的 `return {` 即可。

1. { lua-language-server }
   - 参考发行版（pacman -Ss lua-language-server）
2. { css-language-server --studio, html-language-server }
   - npm install -g vscode-langservers-extracted
3. { intelephense }
   - npm install -g intelephense
4. { typescript-language-server }
   - npm install -g typescript-language-server typescript




完整功能一览：
插件管理 — 自写的 manage.lua，启动时 git clone 插件到 ~/.local/share/nvim/plugins/ 并加入 rtp
编辑器基础（options.lua）
- 相对行号 + 绝对行号
- 4 空格缩进，tab 转空格
- 智能搜索大小写
- true color、dark 背景、signcolumn 常显、光标行高亮、80 列标尺
- clipboard 自动连 unnamedplus（系统剪贴板）
- 上下分屏/左右分屏默认在右/下
- 持久化 undo 到 ~/.vim/undodir，禁用 swap/backup
- scrolloff=8，updatetime=50ms
快捷键（keybinds.lua）
- <space> 是 leader
- J 拼接行不跳光标，<C-d/u> 翻页后居中，n/N 搜索结果居中
- visual 模式 J/K 上下移动选中行
- <leader>d 删除到黑寄存器（不覆盖剪贴板），<leader>p 粘贴不覆盖
- <leader>x 给当前文件加执行权限
- <leader>y OSC yank（SSH 下复制到本地剪贴板）
- <leader>u 切换 undotree
- <C-j/k> quickfix 上下翻，<leader>co/cl/cn/cp quickfix 开关/导航
- <leader>mm 运行 make
- <leader>cc 运行 php-cs-fixer
- <leader>dg 生成 docblock（vim-doge）
- <leader>s 替换光标下单词，<leader>rl 重载配置
代码补全（completion.lua，nvim-cmp）
- LSP 语义补全 + 路径补全 + buffer 补全
- <Tab> 选中下一项，<CR> 确认（不自动选中）
- <C-Space> 手动触发补全，<C-f/u> 滚动文档窗口
Telescope（telescope.lua）
- <leader>ff 查找文件，<leader>fo 最近文件，<leader>fb buffer 列表
- <leader>fh 搜索 help，<leader>fg 全文 grep
- <leader>fc 搜索当前文件名，<leader>fs 搜索光标下单词
- <leader>fi 搜索 nvim 配置目录
Harpoon（harpoon.lua）
- <leader>a 标记文件，<C-e> 打开标记列表
- <C-p/n> 上下切换标记
- <leader>fl 用 Telescope 界面浏览标记
Treesitter（treesitter.lua）
- 自动安装 24 种 parser（json/python/rust/go/ts/…）
- 语法高亮 + 代码缩进
- textobjects: af/if 选中函数内外区域
- treesitter-context: 滚动时固定显示当前函数/类名
外观（colors.lua + one-liners.lua）
- Tokyonight 主题，背景透明
- Lualine 状态栏
- 颜色值高亮（nvim-highlight-colors）
- 各种 icon（nvim-web-devicons）
其他插件
- orgmode — 日程管理（~/orgfiles/）
- vim-fugitive — Git 集成
- undotree — undo 历史可视化
- vim-oscyank — SSH 远程复制
- vim-doge — 自动生成 docblock
- better-indent-support-for-php-with-html — PHP+HTML 缩进修复