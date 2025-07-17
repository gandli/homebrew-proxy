# 项目结构与组织

## 根目录结构

- **Casks/**: 包含所有 Homebrew Cask 定义文件 (*.rb)
- **Formula/**: 包含 Homebrew Formula 定义（目前为空）
- **.github/**: 包含 GitHub 特定文件（工作流、模板、脚本）
- **LICENSE**: MIT 许可证文件
- **Makefile**: 包含常见开发任务的 make 目标
- **README.md**: 项目文档和应用程序列表
- **.editorconfig**: 用于一致代码风格的编辑器配置
- 各种代码检查工具配置文件 (*.yml,*.json)

## Cask 目录

`Casks/` 目录包含定义每个应用程序包的 Ruby (.rb) 文件：

- 每个文件以其安装的应用程序命名（例如，`clash-nyanpasu.rb`）
- 文件遵循 Homebrew Cask DSL（领域特定语言）格式
- 每个 Cask 定义元数据、下载 URL、安装说明和清理操作

## GitHub 目录结构

- **.github/workflows/**: CI/CD 工作流定义
  - **update-casks.yml**: 自动检查应用程序更新
  - **update-readme.yml**: 使用当前应用程序信息更新 README.md
  - 其他用于测试和验证的工作流文件
- **.github/scripts/**: 开发和 CI 的实用脚本
  - **dev-tools.sh**: 主要开发工具脚本
  - **validate-casks.sh**: 验证 Cask 文件的脚本
  - **fix-casks.sh**: 修复 Cask 文件常见问题的脚本
  - **install-tools.sh**: 安装开发工具的脚本
- **.github/ISSUE_TEMPLATE/**: GitHub 问题模板
- **.github/docs/**: 文档文件（建议的组织方式）

## 配置文件

- **.rubocop.yml**: Ruby 代码风格的 RuboCop 配置
- **.rubocop_todo.yml**: RuboCop 规则的临时例外
- **.yamllint.yml**: YAML 代码检查配置
- **.markdownlint.json**: Markdown 代码检查配置
- **.shellcheckrc**: Shell 脚本代码检查配置
- **.pre-commit-config.yaml**: 预提交钩子配置

## Cask 文件结构

每个 Cask 文件遵循以下通用结构：

```ruby
cask "application-name" do
  # 版本和校验和信息
  version "1.2.3"
  sha256 "abcdef123456..."

  # 下载信息
  url "https://example.com/download/app-#{version}.dmg"

  # 元数据
  name "Application Name"
  desc "应用程序的简要描述"
  homepage "https://example.com/"

  # 更新检查配置
  livecheck do
    url :url
    strategy :github_latest
  end

  # 安装说明
  app "Application.app"

  # 清理说明
  zap trash: [
    "~/Library/Application Support/application-name",
    "~/Library/Preferences/com.example.application.plist",
  ]
end
```

## 代码风格与约定

- **缩进**: 所有文件类型使用 2 个空格
- **行长度**: 最大 120 个字符
- **Ruby 风格**: 遵循 `.rubocop.yml` 中定义的 RuboCop 规则
- **Shell 脚本**: 遵循 ShellCheck 指南
- **YAML 文件**: 遵循 yamllint 规则
- **Markdown 文件**: 遵循 markdownlint 规则
- **文件结尾**: 所有文件以换行符结尾
- **尾随空格**: 从所有文件中移除，除了 Markdown 换行符

## 文档组织

- **README.md**: 包含应用程序列表的主要项目文档
- **FORMAT_STANDARDS.md**: 代码格式标准
- **CODE_QUALITY_SETUP.md**: 代码质量工具的设置说明
- **CODE_QUALITY_RECOMMENDATIONS.md**: 改进代码质量的建议
- **WORKSPACE_OPTIMIZATION.md**: 工作空间组织建议
