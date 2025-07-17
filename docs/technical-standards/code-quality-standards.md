# 代码质量标准

本文档定义了Homebrew Proxy Tap项目的代码质量标准和最佳实践。

## 代码质量工具

项目使用以下工具确保代码质量：

- **RuboCop**: Ruby代码风格和质量检查
- **ShellCheck**: Shell脚本静态分析
- **yamllint**: YAML文件格式检查
- **markdownlint**: Markdown文件格式检查
- **pre-commit**: Git提交前自动检查

## Ruby代码标准

### 格式规范

- **缩进**: 2个空格
- **行长度**: 最大120个字符
- **字符串**: 优先使用双引号`"`
- **命名约定**:
  - 变量和方法名使用snake_case
  - 类名使用CamelCase
  - 常量使用SCREAMING_SNAKE_CASE
- **文件结尾**: 所有文件以换行符结尾

### Cask文件标准

- **命名**: 使用小写和连字符，例如`application-name.rb`
- **版本号**: 使用确切的版本号，避免使用"latest"
- **URL**: 使用`#{version}`变量引用版本号
- **SHA256**: 必须提供准确的SHA256校验和
- **描述**: 简洁明了，不超过80个字符
- **Livecheck**: 尽可能配置自动版本检查
- **Zap Stanza**: 包含所有应用程序数据文件

### 示例Cask

```ruby
cask "example-app" do
  version "1.2.3"
  sha256 "abcdef123456..."

  url "https://example.com/download/example-#{version}.dmg"
  name "Example App"
  desc "A concise description of the application"
  homepage "https://example.com/"

  livecheck do
    url :homepage
    strategy :page_match
    regex(/version (\d+\.\d+\.\d+)/i)
  end

  app "Example.app"

  zap trash: [
    "~/Library/Application Support/Example",
    "~/Library/Preferences/com.example.plist",
  ]
end
```

## Shell脚本标准

### Shell格式规范

- **缩进**: 2个空格
- **行长度**: 最大120个字符
- **引号**: 优先使用双引号`"`，除非需要变量扩展
- **命名约定**:
  - 变量名使用小写和下划线
  - 函数名使用小写和下划线
- **文件头**: 包含shebang和简短描述
- **错误处理**: 使用`set -e`或适当的错误检查

### Shell最佳实践

- 使用`set -euo pipefail`增强错误处理
- 为所有函数添加文档注释
- 使用有意义的变量名
- 避免使用全局变量
- 使用函数组织代码
- 添加适当的日志输出

### 示例脚本

```bash
#!/bin/bash
# 描述: 示例脚本，展示代码质量标准

set -euo pipefail

# 全局变量
LOG_FILE="/tmp/example.log"

# 记录消息到日志
# 参数:
#   $1 - 日志级别
#   $2 - 日志消息
log_message() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"

  if [[ "$level" == "ERROR" ]]; then
    echo "[${level}] ${message}" >&2
  else
    echo "[${level}] ${message}"
  fi
}

# 主函数
main() {
  log_message "INFO" "脚本开始执行"

  # 脚本逻辑

  log_message "INFO" "脚本执行完成"
}

# 执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

## YAML文件标准

### YAML格式规范

- **缩进**: 2个空格
- **行长度**: 最大120个字符
- **引号**: 根据需要使用单引号或双引号
- **列表格式**: 使用连字符`-`和空格
- **文件结尾**: 所有文件以换行符结尾

### 示例YAML

```yaml
# GitHub Actions工作流示例
name: Code Quality

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
      - name: Install dependencies
        run: gem install rubocop
      - name: Run linters
        run: rubocop
```

## Markdown文件标准

### Markdown格式规范

- **缩进**: 2个空格（列表缩进）
- **行长度**: 最大120个字符
- **标题格式**: 使用ATX风格（`#`）
- **列表格式**: 使用连字符`-`
- **代码块**: 使用三个反引号和语言标识符
- **文件结尾**: 所有文件以换行符结尾

### Markdown最佳实践

- 使用语义化标题层次
- 添加目录（对于长文档）
- 使用相对链接引用其他文档
- 包含适当的代码示例
- 使用表格组织复杂信息

### 示例Markdown

```markdown
# 文档标题

## 简介

这是一个示例Markdown文档，展示格式标准。

## 功能

- 第一个功能
- 第二个功能
  - 子功能1
  - 子功能2

## 代码示例

```ruby
cask "example" do
  version "1.0.0"
  # 更多代码...
end
```

## 表格

| 名称 | 描述 | 版本 |
|------|------|------|
| 示例1 | 示例描述 | 1.0.0 |
| 示例2 | 另一个描述 | 2.0.0 |

```ruby
cask "example" do
  version "1.0.0"
  # 更多代码...
end
```

## 代码审查标准

在审查代码时，请关注以下方面：

1. **功能性**: 代码是否按预期工作
2. **可读性**: 代码是否易于理解
3. **一致性**: 代码是否遵循项目标准
4. **安全性**: 代码是否存在安全问题
5. **性能**: 代码是否高效
6. **文档**: 代码是否有适当的文档

## 自动化检查

项目使用以下自动化检查确保代码质量：

### 预提交钩子

使用`pre-commit`在提交前运行检查：

```bash
make pre-commit-install
```

### CI/CD检查

GitHub Actions工作流在以下情况下运行代码质量检查：

- 推送到`main`分支
- 创建Pull Request
- 定期计划运行

### 手动检查

您可以使用以下命令手动运行检查：

```bash
# 运行所有代码质量检查
make quality

# 检查特定类型的代码
make quality-ruby
make quality-shell
```

## 持续改进

我们鼓励持续改进代码质量标准：

1. 定期更新工具版本
2. 根据项目需求调整规则
3. 自动修复常见问题
4. 分享最佳实践

如果您有改进建议，请提交Issue或Pull Request。
