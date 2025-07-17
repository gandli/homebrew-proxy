# 开发环境设置

本指南将帮助您设置Homebrew Proxy Tap项目的开发环境。

## 系统要求

- macOS操作系统（推荐最新版本）
- [Homebrew](https://brew.sh/)已安装
- Git
- Ruby（Homebrew自带）
- 基本的命令行知识

## 步骤1：克隆仓库

首先，fork项目仓库，然后克隆到本地：

```bash
# 克隆您的fork
git clone https://github.com/YOUR_USERNAME/homebrew-proxy.git

# 进入项目目录
cd homebrew-proxy

# 添加上游仓库
git remote add upstream https://github.com/gandli/homebrew-proxy.git
```

## 步骤2：安装开发工具

我们提供了一个方便的Makefile来安装所有必要的开发工具：

```bash
# 安装所有开发工具
make install-tools

# 验证工具安装
make install-tools-verify
```

这将安装以下工具：

- **RuboCop**: Ruby代码风格检查器
- **ShellCheck**: Shell脚本静态分析工具
- **yamllint**: YAML文件检查器
- **markdownlint**: Markdown文件检查器
- **pre-commit**: Git钩子管理工具

## 步骤3：设置Git钩子

安装pre-commit钩子以确保代码质量：

```bash
make pre-commit-install
```

这将在每次提交前自动运行代码质量检查。

## 步骤4：设置开发环境

```bash
# 设置开发环境
make setup
```

这将配置您的开发环境，包括必要的依赖项和配置。

## 步骤5：验证设置

运行以下命令验证您的设置是否正确：

```bash
# 检查工具安装状态
make check-tools-verbose

# 运行基本验证
make validate
```

## 常用开发命令

以下是一些在开发过程中常用的命令：

### 代码质量检查

```bash
# 运行所有代码质量检查
make quality

# 检查Ruby代码
make quality-ruby

# 检查Shell脚本
make quality-shell

# 运行lint检查
make lint

# 自动修复lint问题
make lint-fix
```

### Cask管理

```bash
# 验证所有Cask
make validate

# 验证特定Cask
make validate-file FILE=Casks/example.rb

# 修复Cask格式问题
make fix

# 创建新Cask
make new-cask NAME=app-name
```

### 测试

```bash
# 运行所有测试
make test

# 运行单元测试
make test-unit

# 运行集成测试
make test-integration
```

### 其他有用命令

```bash
# 显示项目统计信息
make stats

# 清理项目
make clean

# 显示帮助信息
make help

# 诊断开发环境
make doctor
```

## 目录结构

了解项目的目录结构有助于您更好地导航：

```text
homebrew-proxy/
├── Casks/                  # Homebrew Cask定义
│   ├── clash/              # Clash相关工具
│   ├── v2ray/              # V2Ray相关工具
│   └── others/             # 其他代理工具
├── Formula/                # Homebrew Formula定义（如有）
├── docs/                   # 项目文档
├── scripts/                # 开发和维护脚本
├── .github/                # GitHub相关文件
│   ├── workflows/          # GitHub Actions工作流
│   ├── ISSUE_TEMPLATE/     # Issue模板
│   └── scripts/            # GitHub Action脚本
├── config/                 # 配置文件
└── tests/                  # 测试文件
```

## 故障排除

### 工具安装问题

如果您在安装开发工具时遇到问题：

```bash
# 检查工具安装状态
make check-tools-verbose

# 手动安装特定工具
make install-shellcheck
make rubocop-install
make install-yamllint
make install-markdownlint
```

### pre-commit钩子问题

如果pre-commit钩子失败：

```bash
# 更新pre-commit钩子
pre-commit autoupdate

# 清理缓存
pre-commit clean

# 重新安装
pre-commit uninstall
pre-commit install
```

### 其他问题

如果您遇到其他问题，请：

1. 运行`make doctor`检查环境
2. 查看相关工具的文档
3. 在GitHub上创建Issue寻求帮助

## 下一步

设置完成后，您可以：

- 阅读[贡献指南](./contributing.md)了解如何贡献
- 查看[Cask创建指南](./cask-creation.md)学习如何创建和维护Cask
- 浏览[GitHub Issues](https://github.com/gandli/homebrew-proxy/issues)寻找可以帮助解决的问题
