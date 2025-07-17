# 🤝 贡献指南

欢迎为 homebrew-proxy 项目做出贡献！本指南将帮助您了解如何参与项目开发。

## 📋 目录

- [开始之前](#%E5%BC%80%E5%A7%8B%E4%B9%8B%E5%89%8D)
- [添加新的 Cask](#%E6%B7%BB%E5%8A%A0%E6%96%B0%E7%9A%84-cask)
- [修改现有 Cask](#%E4%BF%AE%E6%94%B9%E7%8E%B0%E6%9C%89-cask)
- [代码规范](#%E4%BB%A3%E7%A0%81%E8%A7%84%E8%8C%83)
- [测试流程](#%E6%B5%8B%E8%AF%95%E6%B5%81%E7%A8%8B)
- [提交 PR](#%E6%8F%90%E4%BA%A4-pr)
- [常见问题](#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)

## 🚀 开始之前

### 环境要求

- macOS 系统
- 已安装 Homebrew
- Git 基础知识
- 基本的 Ruby 语法了解

### 克隆仓库

```bash
# 克隆仓库
git clone https://github.com/gandli/homebrew-proxy.git
cd homebrew-proxy

# 添加 tap
brew tap gandli/proxy
```

## 📦 添加新的 Cask

### 1. 创建 Cask 文件

使用以下模板创建新的 Cask 文件：

```ruby
cask "your-app-name" do
  arch arm: "arm64", intel: "x64"  # 根据实际情况调整

  version "1.0.0"  # 最新版本号
  sha256 arm:   "arm64_sha256_hash",
         intel: "intel_sha256_hash"

  url "https://github.com/owner/repo/releases/download/#{version}/app-#{arch}.dmg"
  name "App Display Name"
  desc "Application description"
  homepage "https://github.com/owner/repo"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true  # 如果应用支持自动更新

  app "YourApp.app"

  # 可选：预处理脚本
  preflight do
    system_command "xattr",
                   args: ["-cr", "#{staged_path}/YourApp.app"]
  end

  # 卸载清理
  zap trash: [
    "~/Library/Application Support/YourApp",
    "~/Library/Preferences/com.company.yourapp.plist",
    "~/Library/Caches/com.company.yourapp",
    "~/Library/Logs/YourApp",
  ]
end
```

### 2. 获取 SHA256 值

```bash
# 下载文件并计算 SHA256
wget "download_url"
shasum -a 256 filename
```

### 3. 验证 Cask

```bash
# 验证语法
brew audit --cask Casks/your-app-name.rb

# 使用项目验证脚本
./.github/scripts/validate-casks.sh Casks/your-app-name.rb

# 测试安装
brew install --cask gandli/proxy/your-app-name
```

## 🔧 修改现有 Cask

### 版本更新

1. 更新 `version` 字段
2. 更新对应的 `sha256` 值
3. 检查 `url` 是否需要调整
4. 运行验证脚本

### 添加缺失功能

- **Livecheck**: 确保所有 Cask 都有 `livecheck` 配置
- **多架构支持**: 为支持的应用添加 ARM64 和 Intel 版本
- **Zap 配置**: 添加完整的卸载清理配置

## 📏 代码规范

### 必须遵循的规范

1. **缩进**: 使用 2 个空格，不使用 Tab
2. **Livecheck**: 所有 Cask 必须包含 `livecheck` 配置
3. **多架构**: 优先支持多架构（ARM64 + Intel）
4. **HTTPS**: 所有 URL 必须使用 HTTPS
5. **Zap 配置**: 必须包含完整的卸载清理配置

### 字段顺序

```ruby
cask "name" do
  arch          # 架构配置（如果需要）
  version       # 版本号
  sha256        # 校验和
  url           # 下载链接
  name          # 显示名称
  desc          # 描述
  homepage      # 主页
  livecheck     # 版本检查
  auto_updates  # 自动更新（可选）
  depends_on    # 依赖（可选）
  app           # 安装目标
  preflight     # 预处理（可选）
  postflight    # 后处理（可选）
  zap           # 卸载清理
end
```

### 命名规范

- Cask 名称使用小写字母和连字符
- 文件名与 Cask 名称一致
- 避免使用版本号或架构信息

## 🧪 测试流程

### 自动化测试

```bash
# 运行所有验证
./.github/scripts/validate-casks.sh --all

# 修复常见问题
./.github/scripts/fix-casks.sh --all --dry-run  # 预览
./.github/scripts/fix-casks.sh --all            # 执行修复
```

### 手动测试

```bash
# 语法检查
brew audit --cask Casks/app-name.rb

# 安装测试
brew install --cask gandli/proxy/app-name

# 卸载测试
brew uninstall --cask app-name
brew uninstall --zap --cask app-name  # 测试 zap 配置
```

## 📝 提交 PR

### PR 标题格式

- `feat: add new cask for AppName`
- `fix: update AppName to version X.Y.Z`
- `docs: update README for AppName`
- `refactor: improve AppName cask structure`

### PR 描述模板

```markdown
## 📋 变更类型
- [ ] 新增 Cask
- [ ] 更新版本
- [ ] 修复问题
- [ ] 文档更新
- [ ] 其他

## 📦 相关应用
- 应用名称:
- 版本号:
- 官方网站:

## ✅ 检查清单
- [ ] 通过语法检查 (`brew audit`)
- [ ] 通过项目验证脚本
- [ ] 测试安装和卸载
- [ ] 包含完整的 zap 配置
- [ ] 包含 livecheck 配置
- [ ] 支持多架构（如适用）

## 📝 额外说明
（如有需要，请添加额外说明）
```

### 提交流程

1. Fork 仓库
2. 创建功能分支: `git checkout -b feature/add-app-name`
3. 提交变更: `git commit -m "feat: add new cask for AppName"`
4. 推送分支: `git push origin feature/add-app-name`
5. 创建 Pull Request

## ❓ 常见问题

### Q: 如何处理多架构应用？

A: 使用 `arch` 配置：

```ruby
arch arm: "arm64", intel: "x64"
sha256 arm:   "arm64_hash",
       intel: "intel_hash"
url "https://example.com/app-#{arch}.dmg"
```

### Q: 如何添加 livecheck 配置？

A: 对于 GitHub 项目：

```ruby
livecheck do
  url :url
  strategy :github_latest
end
```

对于其他来源，参考 [Homebrew Livecheck 文档](https://docs.brew.sh/Brew-Livecheck)。

### Q: 如何确定 zap 配置？

A: 安装应用后，检查以下位置：

- `~/Library/Application Support/`
- `~/Library/Preferences/`
- `~/Library/Caches/`
- `~/Library/Logs/`
- `~/Library/LaunchAgents/`

### Q: 验证脚本报错怎么办？

A: 查看具体错误信息：

1. 检查缩进是否为 2 个空格
2. 确认所有必需字段都存在
3. 验证 URL 是否使用 HTTPS
4. 检查 livecheck 配置是否正确

### Q: 如何处理应用签名问题？

A: 添加 preflight 脚本：

```ruby
preflight do
  system_command "xattr",
                 args: ["-cr", "#{staged_path}/YourApp.app"]
end
```

## 📞 获取帮助

- 创建 [Issue](https://github.com/gandli/homebrew-proxy/issues) 报告问题
- 查看 [Homebrew Cask 文档](https://docs.brew.sh/Cask-Cookbook)
- 参考现有 Cask 文件作为示例

## 🙏 致谢

感谢所有为项目做出贡献的开发者！您的贡献让这个项目变得更好。

## 📄 许可证

通过向本项目提交贡献，您同意您的贡献将遵循 [MIT 许可证](../LICENSE)。

本项目采用 MIT 许可证开源，这意味着：

- ✅ 可以自由使用、修改和分发
- ✅ 可以用于商业用途
- ✅ 可以私有使用
- ⚠️ 必须保留版权声明和许可证声明
- ⚠️ 不提供任何担保

---

> 📅 最后更新: 2024-01-01
> 📖 更多信息请查看 [项目文档](../README.md)
