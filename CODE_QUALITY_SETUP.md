# 代码质量检查设置指南

本文档介绍了 `homebrew-proxy` 项目的代码质量检查工具配置和使用方法。

## 📋 概述

项目已配置了全面的代码质量检查工具，包括：

- **ShellCheck**: Shell 脚本静态分析
- **RuboCop**: Ruby 代码风格和质量检查
- **yamllint**: YAML 文件格式检查
- **markdownlint**: Markdown 文件格式检查
- **pre-commit**: Git 提交前自动检查
- **GitHub Actions**: 持续集成中的自动化检查

## 🛠️ 工具安装

### 自动安装（推荐）

使用项目提供的安装脚本：

```bash
# 安装所有工具
make install-tools

# 或者使用脚本直接安装
./.github/scripts/install-tools.sh --all

# 验证安装
make install-tools-verify
```

### 手动安装

#### 1. ShellCheck

```bash
# macOS (Homebrew)
brew install shellcheck

# Ubuntu/Debian
sudo apt-get install shellcheck

# 或使用安装脚本
make install-shellcheck
```

#### 2. RuboCop

```bash
# 使用 gem 安装
gem install rubocop

# 或使用 Makefile
make rubocop-install
```

#### 3. yamllint

```bash
# 使用 pip 安装
pip install yamllint
# 或
pip3 install yamllint

# 或使用安装脚本
make install-yamllint
```

#### 4. markdownlint

```bash
# 使用 npm 安装
npm install -g markdownlint-cli

# 或使用安装脚本
make install-markdownlint
```

#### 5. pre-commit

```bash
# 使用 pip 安装
pip install pre-commit
# 或
brew install pre-commit

# 安装钩子
make pre-commit-install
```

## ⚙️ 配置文件

项目包含以下配置文件：

### `.shellcheckrc`

ShellCheck 配置文件，定义了检查规则和排除项。

### `.rubocop.yml`

RuboCop 配置文件，针对 Homebrew Cask 文件进行了优化。

### `.yamllint.yml`

YAML 文件检查配置，包括缩进、行长度等规则。

### `.markdownlint.json`

Markdown 文件格式检查配置。

### `.pre-commit-config.yaml`

Pre-commit 钩子配置，集成了所有质量检查工具。

## 🚀 使用方法

### 基础检查

```bash
# 运行所有代码质量检查
make quality

# 运行基础代码检查
make lint

# 检查特定类型的代码
make quality-ruby      # 检查 Ruby 代码
make quality-shell     # 检查 Shell 脚本
```

### 使用开发工具脚本

```bash
# 运行完整质量检查
./.github/scripts/dev-tools.sh quality

# 运行特定检查
./.github/scripts/dev-tools.sh quality --ruby
./.github/scripts/dev-tools.sh quality --shell
```

### Pre-commit 使用

```bash
# 安装 pre-commit 钩子
make pre-commit-install

# 手动运行 pre-commit 检查
make pre-commit-run

# 在所有文件上运行
pre-commit run --all-files
```

## 🔧 自定义配置

### 修改 RuboCop 规则

编辑 `.rubocop.yml` 文件来自定义 Ruby 代码检查规则：

```yaml
# 示例：修改行长度限制
Layout/LineLength:
  Max: 120
  Exclude:
    - 'Casks/**/*'
```

### 生成 RuboCop TODO 文件

```bash
# 生成当前违规的 TODO 文件
make rubocop-config

# 或直接使用 RuboCop
rubocop --auto-gen-config
```

### 修改 ShellCheck 规则

编辑 `.shellcheckrc` 文件：

```bash
# 禁用特定规则
disable=SC1091,SC2034

# 设置严格性级别
severity=warning
```

## 🤖 GitHub Actions 集成

项目配置了 `.github/workflows/code-quality.yml` 工作流，在以下情况下自动运行：

- 推送到 `main` 或 `develop` 分支
- 创建 Pull Request
- 每周一凌晨 2 点定时运行

工作流包括：

1. **ShellCheck**: 检查 Shell 脚本
2. **yamllint**: 检查 YAML 文件
3. **markdownlint**: 检查 Markdown 文件
4. **RuboCop**: 检查 Ruby 代码
5. **pre-commit**: 运行所有 pre-commit 钩子
6. **安全检查**: 使用 Trivy 进行漏洞扫描
7. **依赖检查**: 检查敏感信息泄露

## 📊 质量报告

### 查看项目统计

```bash
# 显示项目统计信息
make stats

# 或使用开发工具脚本
./.github/scripts/dev-tools.sh stats
```

### 检查工具安装状态

```bash
# 详细检查工具安装状态
make check-tools-verbose

# 验证工具安装
make install-tools-verify
```

## 🐛 故障排除

### 常见问题

#### 1. RuboCop 报告大量违规

```bash
# 生成 TODO 文件暂时忽略现有违规
make rubocop-config

# 自动修复可修复的问题
rubocop --auto-correct
```

#### 2. pre-commit 钩子失败

```bash
# 更新 pre-commit 钩子
pre-commit autoupdate

# 清理缓存
pre-commit clean

# 重新安装
pre-commit uninstall
pre-commit install
```

#### 3. 工具未找到

```bash
# 检查工具安装状态
make check-tools-verbose

# 重新安装工具
make install-tools
```

### 跳过特定检查

#### 临时跳过 pre-commit 检查

```bash
# 跳过所有 pre-commit 钩子
git commit --no-verify -m "commit message"

# 跳过特定钩子
SKIP=rubocop git commit -m "commit message"
```

#### 在文件中禁用特定规则

```ruby
# 在 Ruby 文件中禁用 RuboCop 规则
# rubocop:disable Style/StringLiterals
cask 'example' do
  # ...
end
# rubocop:enable Style/StringLiterals
```

```bash
# 在 Shell 脚本中禁用 ShellCheck 规则
# shellcheck disable=SC2086
echo $variable
```

## 📚 最佳实践

### 1. 提交前检查

- 始终在提交前运行 `make quality`
- 使用 pre-commit 钩子自动化检查
- 修复所有质量问题后再提交

### 2. 持续改进

- 定期更新 `.rubocop_todo.yml` 文件
- 逐步修复历史违规
- 保持配置文件的更新

### 3. 团队协作

- 确保所有团队成员安装了相同的工具
- 统一使用项目配置文件
- 在 PR 中检查质量报告

## 🔗 相关链接

- [ShellCheck 文档](https://github.com/koalaman/shellcheck)
- [RuboCop 文档](https://rubocop.org/)
- [yamllint 文档](https://yamllint.readthedocs.io/)
- [markdownlint 文档](https://github.com/DavidAnson/markdownlint)
- [pre-commit 文档](https://pre-commit.com/)
- [Homebrew Cask 风格指南](https://docs.brew.sh/Cask-Cookbook)

## 📝 贡献

如果您发现配置问题或有改进建议，请：

1. 创建 Issue 描述问题
2. 提交 Pull Request 包含修复
3. 更新相关文档

## 📄 许可证

本文档和相关配置文件遵循项目的 [MIT 许可证](LICENSE)。您可以自由使用、修改和分发这些配置，但请保留版权声明。

---

通过遵循这些代码质量检查标准，我们可以确保项目代码的一致性、可读性和可维护性。
