# 技术栈与构建系统

## 技术栈

- **Ruby**: 用于 Homebrew Cask 定义的主要语言
- **Shell 脚本**: 用于自动化、验证和实用脚本
- **YAML**: 用于配置文件和 GitHub Actions 工作流
- **Markdown**: 用于文档

## 构建与开发工具

- **Homebrew**: 此 tap 扩展的包管理器
- **RuboCop**: Ruby 代码风格检查器和格式化工具
- **ShellCheck**: Shell 脚本静态分析工具
- **yamllint**: YAML 文件代码检查工具
- **markdownlint**: Markdown 文件代码检查工具
- **pre-commit**: 用于代码质量检查的 Git 钩子框架

## CI/CD 流水线

- **GitHub Actions**: 用于持续集成和部署
- **自动化测试**: 验证 Cask 文件并检查更新
- **自动化文档**: 生成和更新 README.md

## 常用命令

### 安装命令

```bash
# 安装特定的 cask
brew install gandli/proxy/<cask_name>

# 添加 tap 然后安装
brew tap gandli/proxy
brew install --cask <cask_name>

# 使用 Brewfile
brew bundle  # 使用包含 tap 和 casks 的 Brewfile
```

### 开发命令

```bash
# 设置开发环境
make setup

# 验证所有 Cask 文件
make validate

# 修复格式问题
make fix

# 运行测试
make test

# 检查代码质量
make quality

# 创建新的 Cask 模板
make new-cask NAME=app-name

# 安装预提交钩子
make pre-commit-install

# 手动运行预提交检查
make pre-commit-run
```

### 实用工具命令

```bash
# 显示项目统计信息
make stats

# 清理项目文件
make clean

# 生成 RuboCop TODO 配置
make rubocop-config

# 安装开发工具
make install-tools

# 验证工具安装
make install-tools-verify
```

## 开发环境设置

### 先决条件

- **macOS**: Homebrew 所需
- **Homebrew**: 必须已安装
- **Git**: 用于版本控制
- **Ruby**: macOS 自带，但确保是最新版本

### 初始设置

1. 克隆仓库
2. 运行 `make setup` 安装开发依赖
3. 运行 `make pre-commit-install` 设置 Git 钩子
4. 使用 `make validate` 验证设置

## 测试策略

### 自动化测试

- **Cask 验证**: 确保所有 Cask 文件语法正确
- **链接验证**: 检查下载 URL 是否可访问
- **版本一致性**: 验证版本号和校验和
- **风格合规性**: 在所有文件中强制执行编码标准

### 手动测试

- **安装测试**: 验证 casks 在干净系统上正确安装
- **更新测试**: 确保 cask 更新正常工作
- **卸载测试**: 确认应用程序的干净移除

## 版本控制与更新

### 版本管理

- **语义化版本**: 应用程序根据上游发布进行版本控制
- **自动化更新**: GitHub Actions 工作流自动检查更新
- **手动更新**: 为版本更新创建拉取请求

### 更新流程

1. **检测**: 自动化脚本检查新的应用程序版本
2. **验证**: 验证所有下载的 SHA256 校验和
3. **集成**: 更新在通过所有检查后合并
4. **分发**: 更新的 casks 立即可供用户使用
