# 🎯 交互式开发指南

欢迎使用Homebrew Proxy Tap项目的交互式开发指南。本指南将帮助您快速开始开发和贡献。

## 快速开始

选择您的开发场景:

- [🆕 添加新的Cask](#adding-new-cask)
- [🔧 修复现有Cask](#fixing-existing-cask)
- [🧪 运行测试](#running-tests)
- [📦 发布更新](#releasing-updates)
- [🔍 代码质量检查](#code-quality-checks)

## 添加新的Cask {#adding-new-cask}

### 步骤1: 创建Cask文件

```bash
make new-cask NAME=your-app-name
```

这将在`Casks/`目录中创建一个基本的Cask模板文件。

### 步骤2: 填写应用信息

编辑生成的模板，填写以下信息:

- [ ] 应用名称和描述
- [ ] 下载链接和SHA256校验和
- [ ] 版本信息
- [ ] Livecheck配置

示例:

```ruby
cask "example-app" do
  version "1.2.3"
  sha256 "abcdef123456..."

  url "https://example.com/download/example-#{version}.dmg"
  name "Example App"
  desc "A brief description of the application"
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

### 步骤3: 验证Cask

```bash
make validate-file FILE=Casks/your-app-name.rb
```

### 步骤4: 测试安装

```bash
make install-cask NAME=your-app-name
```

### 步骤5: 提交PR

```bash
git add Casks/your-app-name.rb
git commit -m "Add: new cask for your-app-name"
git push origin your-branch-name
```

## 修复现有Cask {#fixing-existing-cask}

### 步骤1: 找到需要修复的Cask

```bash
# 列出所有Cask
ls Casks/

# 或者搜索特定Cask
find Casks/ -name "*clash*.rb"
```

### 步骤2: 验证当前状态

```bash
make validate-file FILE=Casks/app-name.rb
```

### 步骤3: 修复问题

常见修复:

1. **更新版本和SHA256**:

```ruby
# 旧版本
version "1.2.3"
sha256 "old-sha256-value"

# 新版本
version "1.2.4"
sha256 "new-sha256-value"
```

1. **修复下载链接**:

```ruby
# 旧链接
url "https://example.com/download/v1.2.3/app.dmg"

# 新链接
url "https://example.com/download/v#{version}/app.dmg"
```

1. **修复livecheck**:

```ruby
# 添加或修复livecheck
livecheck do
  url "https://example.com/releases"
  regex(/v(\d+\.\d+\.\d+)/i)
end
```

### 步骤4: 验证修复

```bash
make validate-file FILE=Casks/app-name.rb
```

### 步骤5: 测试安装

```bash
make install-cask NAME=app-name
```

## 运行测试 {#running-tests}

### 运行所有测试

```bash
make test
```

### 运行特定类型的测试

```bash
# 单元测试
make test-unit

# 集成测试
make test-integration
```

### 测试特定Cask

```bash
brew install --cask ./Casks/app-name.rb
```

## 发布更新 {#releasing-updates}

### 步骤1: 准备发布

```bash
make release-prepare
```

### 步骤2: 生成变更日志

```bash
make release-changelog
```

### 步骤3: 创建发布标签

```bash
make release-tag
```

## 代码质量检查 {#code-quality-checks}

### 运行所有质量检查

```bash
make quality
```

### 运行特定检查

```bash
# Ruby代码检查
make quality-ruby

# Shell脚本检查
make quality-shell

# 基本lint检查
make lint
```

### 自动修复问题

```bash
# 修复所有Cask文件
make fix

# 修复特定Cask文件
make fix-file FILE=Casks/app-name.rb

# 修复lint问题
make lint-fix
```

## 常见问题解决方案

<details>
<summary>❓ SHA256校验失败</summary>

**问题**: 下载的文件与预期的SHA256不匹配

**解决方案**:

1. 重新下载文件并计算SHA256:

   ```bash
   curl -L "https://example.com/download/app.dmg" -o /tmp/app.dmg
   shasum -a 256 /tmp/app.dmg
   ```

2. 检查下载链接是否正确
3. 确认版本号是否匹配
4. 更新Cask文件中的SHA256值

</details>

<details>
<summary>❓ Livecheck不工作</summary>

**问题**: 自动版本检查不工作

**解决方案**:

1. 检查GitHub仓库是否存在
2. 尝试不同的livecheck策略:

   ```ruby
   # GitHub发布
   livecheck do
     url "https://github.com/user/repo/releases"
     strategy :github_latest
   end

   # 页面匹配
   livecheck do
     url "https://example.com/download"
     regex(/version (\d+\.\d+\.\d+)/i)
   end

   # JSON API
   livecheck do
     url "https://api.example.com/version"
     strategy :json
     regex(/"version"\s*:\s*"(\d+\.\d+\.\d+)"/i)
   end
   ```

3. 手动测试livecheck:

   ```bash
   brew livecheck --cask Casks/app-name.rb
   ```

</details>

<details>
<summary>❓ 安装失败</summary>

**问题**: 应用程序安装失败

**解决方案**:

1. 检查应用程序包结构:

   ```bash
   # 挂载DMG查看内容
   hdiutil attach /tmp/app.dmg
   ls -la /Volumes/AppName/
   ```

2. 确认安装stanza是否正确:

   ```ruby
   # 对于.app文件
   app "AppName.app"

   # 对于.pkg安装程序
   pkg "Install.pkg"

   # 对于多个应用程序
   app ["App1.app", "App2.app"]
   ```

3. 检查权限问题:

   ```bash
   # 查看文件权限
   ls -la /Volumes/AppName/AppName.app
   ```

</details>

## 获取更多帮助

- 查看[贡献指南](./contributor-guides/contributing.md)
- 阅读[开发环境设置](./contributor-guides/development-setup.md)
- 参考[Cask创建指南](./contributor-guides/cask-creation.md)
- 查看[故障排除指南](./user-guides/troubleshooting.md)
- 在GitHub上[提交Issue](https://github.com/gandli/homebrew-proxy/issues)
