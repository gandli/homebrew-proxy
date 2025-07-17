# 📦 Release 创建指南

本指南将帮助您为 Homebrew Proxy Tap 创建发布版本，包含 Casks 目录下的所有代理应用程序。

## 🎯 概述

我们提供了两种创建 Release 的方式：

1. **自动化方式**：通过 GitHub Actions 工作流程
2. **手动方式**：使用本地脚本

## 🤖 方式一：GitHub Actions 自动创建（推荐）

### 手动触发

1. 访问 GitHub 仓库的 Actions 页面
2. 选择 "Create Release" 工作流程
3. 点击 "Run workflow" 按钮
4. 可选配置：
   - **版本号**：留空则自动生成（格式：v2024.01.15）
   - **预发布**：选择是否为预发布版本
5. 点击 "Run workflow" 开始执行

### 自动触发

- **定时触发**：每月1号自动创建新的 Release
- **版本格式**：`v年.月.日`（如：v2024.01.15）

### 工作流程功能

- ✅ 自动提取所有 Cask 应用信息
- ✅ 生成详细的发布说明
- ✅ 检查版本是否已存在，避免重复创建
- ✅ 支持预发布版本
- ✅ 自动清理临时文件
- ✅ 提供详细的执行摘要

## 🛠️ 方式二：本地脚本创建

### 前置要求

确保已安装以下工具：

```bash
# 安装 GitHub CLI 和 jq
brew install gh jq

# 登录 GitHub CLI
gh auth login
```

### 使用步骤

1. **进入项目目录**：
   ```bash
   cd /path/to/homebrew-proxy
   ```

2. **运行创建脚本**：
   ```bash
   ./create-release.sh
   ```

3. **按提示操作**：
   - 确认版本号
   - 检查发布说明
   - 确认创建 Release

### 脚本功能

- 🔍 自动检查依赖工具
- 📋 从 Cask 文件提取应用信息
- 📝 生成详细的发布说明
- 🏷️ 创建 Git 标签
- 🚀 推送到远程仓库
- 📦 创建 GitHub Release
- 🧹 自动清理临时文件

## 📋 Release 内容

每个 Release 将包含：

### 📦 应用程序信息表格

| 应用名称 | 描述 | 版本 | 安装命令 | 主页 |
|---------|------|------|----------|------|
| clash-nyanpasu | Clash GUI based on Tauri | `1.6.1` | `brew install gandli/proxy/clash-nyanpasu` | [🔗](https://github.com/LibNyanpasu/clash-nyanpasu) |
| ... | ... | ... | ... | ... |

### 🚀 安装说明

- 直接安装方式
- Tap 安装方式
- Brewfile 安装方式

### 📈 更新内容

- 应用程序数量统计
- 版本更新信息
- 技术改进说明

### 📞 支持信息

- 文档链接
- 问题反馈渠道
- 贡献指南

## 🔧 版本号规则

### 自动生成格式

- **格式**：`v年.月.日`
- **示例**：`v2024.01.15`、`v2024.12.31`

### 手动指定格式

- **语义化版本**：`v1.0.0`、`v2.1.3`
- **日期版本**：`v2024.01.15`
- **自定义版本**：`v1.0.0-beta.1`

## 🚨 注意事项

### 权限要求

- 需要仓库的 **write** 权限
- GitHub Actions 需要 `contents: write` 权限

### 版本冲突

- 自动检查版本是否已存在
- 本地脚本支持删除现有标签重新创建
- GitHub Actions 会跳过已存在的版本

### 网络要求

- 需要访问 GitHub API
- 本地脚本需要 GitHub CLI 认证

## 🔍 故障排除

### 常见问题

1. **GitHub CLI 未认证**
   ```bash
   gh auth login
   ```

2. **权限不足**
   - 检查仓库权限
   - 确认 GitHub token 权限

3. **版本已存在**
   - 使用不同的版本号
   - 或删除现有版本重新创建

4. **网络连接问题**
   - 检查网络连接
   - 确认 GitHub 服务状态

### 调试模式

本地脚本支持详细的日志输出，可以帮助诊断问题：

```bash
# 查看脚本执行过程
bash -x ./create-release.sh
```

## 📚 相关文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GitHub CLI 文档](https://cli.github.com/manual/)
- [Homebrew Cask 文档](https://docs.brew.sh/Cask-Cookbook)
- [语义化版本规范](https://semver.org/lang/zh-CN/)

## 🤝 贡献

如果您发现本指南有任何问题或需要改进的地方，欢迎：

1. 提交 Issue 报告问题
2. 提交 Pull Request 改进文档
3. 分享使用经验和建议

---

**快速开始**：推荐使用 GitHub Actions 方式，只需在仓库页面点击几下即可完成 Release 创建！