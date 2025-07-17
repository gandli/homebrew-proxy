# 🔧 开发脚本工具集

本目录包含了 `homebrew-proxy` 项目的开发和维护脚本工具。

## 📋 脚本列表

### 🛠️ dev-tools.sh - 统一开发工具入口

**主要脚本**，提供所有开发任务的统一入口点。

```bash
# 基本用法
./dev-tools.sh [command] [options]

# 常用命令
./dev-tools.sh validate --all     # 验证所有 Cask 文件
./dev-tools.sh fix --all          # 修复所有 Cask 文件
./dev-tools.sh test --all         # 运行所有测试
./dev-tools.sh setup              # 设置开发环境
./dev-tools.sh help               # 显示帮助信息
```

**功能特性：**

- ✅ 统一的命令行界面
- ✅ 彩色输出和友好的用户体验
- ✅ 完整的错误处理
- ✅ 支持调试和详细模式
- ✅ 干运行模式支持

### ✅ validate-casks.sh - Cask 文件验证

验证 Cask 文件是否符合项目标准和 Homebrew 规范。

```bash
# 验证所有文件
./validate-casks.sh --all

# 验证单个文件
./validate-casks.sh Casks/clash-nyanpasu.rb
```

**检查项目：**

- ✅ 必需字段完整性（version, sha256, url, name, desc, homepage）
- ✅ Livecheck 配置
- ✅ 多架构支持
- ✅ 代码格式和缩进
- ✅ 清理配置（zap）
- ✅ HTTPS URL 使用
- ✅ Homebrew audit 检查

### 🔧 fix-casks.sh - Cask 文件修复

自动修复 Cask 文件中的常见格式问题。

```bash
# 修复所有文件
./fix-casks.sh --all

# 修复单个文件
./fix-casks.sh Casks/clash-nyanpasu.rb

# 干运行模式（仅显示需要修复的内容）
DRY_RUN=1 ./fix-casks.sh --all
```

**修复功能：**

- ✅ 缩进标准化（2 空格）
- ✅ Livecheck 块格式化
- ✅ 代码结构优化
- ✅ 语法错误修复

## 🚀 快速开始

### 1. 设置开发环境

```bash
# 一键设置开发环境
./dev-tools.sh setup

# 或分步设置
./dev-tools.sh setup --deps    # 检查依赖
./dev-tools.sh setup --hooks   # 设置 Git hooks
./dev-tools.sh setup --config  # 配置开发环境
```

### 2. 日常开发工作流

```bash
# 1. 验证现有 Cask 文件
./dev-tools.sh validate --all

# 2. 修复发现的问题
./dev-tools.sh fix --all

# 3. 再次验证确保修复成功
./dev-tools.sh validate --all

# 4. 运行测试
./dev-tools.sh test --all
```

### 3. 添加新 Cask 文件

```bash
# 1. 创建新的 Cask 文件
vim Casks/new-app.rb

# 2. 验证新文件
./dev-tools.sh validate --file Casks/new-app.rb

# 3. 修复格式问题（如果有）
./dev-tools.sh fix --file Casks/new-app.rb

# 4. 最终验证
./dev-tools.sh validate --file Casks/new-app.rb
```

## 🔍 脚本输出说明

### 日志级别

- 🔵 **信息 (ℹ️)**：一般信息和状态更新
- 🟢 **成功 (✅)**：操作成功完成
- 🟡 **警告 (⚠️)**：需要注意但不影响功能的问题
- 🔴 **错误 (❌)**：需要修复的严重问题
- 🟣 **步骤 (🔧)**：当前执行的操作步骤

### 验证结果解读

```bash
=== 验证报告 ===
ℹ️  总 Cask 数量: 10
✅ 完全通过: 3
⚠️  有警告的 Cask: 7 (总警告数: 15)
❌ 验证失败: 0
ℹ️  成功率: 100%
```

- **完全通过**：没有任何问题的 Cask 文件
- **有警告**：功能正常但有改进空间的文件
- **验证失败**：有严重问题需要修复的文件
- **成功率**：(完全通过 + 有警告) / 总数 × 100%

## 🛠️ 高级用法

### 环境变量

```bash
# 启用调试模式
DEBUG=1 ./dev-tools.sh validate --all

# 启用详细输出
VERBOSE=1 ./dev-tools.sh fix --all

# 干运行模式（仅显示操作，不实际执行）
DRY_RUN=1 ./dev-tools.sh fix --all
```

### 集成到 CI/CD

```yaml
# GitHub Actions 示例
- name: 验证 Cask 文件
  run: |
    chmod +x .github/scripts/dev-tools.sh
    .github/scripts/dev-tools.sh validate --all

- name: 修复格式问题
  run: |
    .github/scripts/dev-tools.sh fix --all

- name: 运行测试
  run: |
    .github/scripts/dev-tools.sh test --all
```

### Git Hooks 集成

脚本会自动设置 pre-commit hook，在每次提交前验证 Cask 文件：

```bash
# 设置 Git hooks
./dev-tools.sh setup --hooks

# 现在每次 git commit 都会自动运行验证
git commit -m "Add new cask"
# 🔍 运行 pre-commit 检查...
# ✅ 所有 Cask 文件验证通过！
```

## 📊 项目统计

```bash
# 查看项目统计信息
./dev-tools.sh stats

# 查看 Cask 文件统计
./dev-tools.sh stats --casks

# 查看提交统计
./dev-tools.sh stats --commits

# 查看贡献者统计
./dev-tools.sh stats --contributors
```

## 🔧 故障排除

### 常见问题

#### 1. 脚本权限问题

```bash
# 解决方案：添加执行权限
chmod +x .github/scripts/*.sh
```

#### 2. Homebrew 未安装

```bash
# 解决方案：安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 3. 验证失败但不知道具体问题

```bash
# 解决方案：启用详细模式
VERBOSE=1 ./dev-tools.sh validate --file Casks/problematic-cask.rb
```

#### 4. 修复脚本没有效果

```bash
# 解决方案：检查文件权限和备份
ls -la Casks/
# 确保文件可写，检查是否有 .bak 备份文件
```

### 获取帮助

```bash
# 查看详细帮助
./dev-tools.sh help

# 查看特定命令的帮助
./dev-tools.sh validate --help
```

## 🤝 贡献

如果你想改进这些脚本：

1. 🍴 Fork 项目
2. 🌟 创建功能分支
3. ✅ 测试你的更改
4. 📝 更新相关文档
5. 🚀 提交 Pull Request

### 脚本开发规范

- ✅ 使用 `set -euo pipefail` 确保错误处理
- ✅ 提供彩色输出和友好的用户体验
- ✅ 包含详细的错误信息和建议
- ✅ 支持调试和详细模式
- ✅ 添加适当的注释和文档
- ✅ 遵循项目的代码风格

---

> 💡 **提示**：建议将 `dev-tools.sh` 添加到你的 shell 别名中，以便快速访问：
>
> ```bash
> # 添加到 ~/.bashrc 或 ~/.zshrc
> alias hb-dev='./github/scripts/dev-tools.sh'
> ```
