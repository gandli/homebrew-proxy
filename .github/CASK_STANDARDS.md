# Cask 文件标准化指南

本文档定义了项目中 Cask 文件的标准化规范和最佳实践。

## 📋 标准化检查清单

### ✅ 已完成的标准化改进

#### 1. Livecheck 配置完善

所有 Cask 文件现已包含 `livecheck` 配置，确保自动更新功能完整：

- ✅ **hiddify.rb** - 添加了 `github_latest` 策略
- ✅ **flclash.rb** - 添加了 `github_latest` 策略  
- ✅ **clash-nyanpasu.rb** - 添加了 `github_latest` 策略
- ✅ **sfm.rb** - 添加了 `github_latest` 策略
- ✅ **clashx-meta.rb** - 已有配置
- ✅ **clash-verge-rev.rb** - 已有配置
- ✅ **mihomo-party.rb** - 已有配置
- ✅ **v2rayn.rb** - 已有配置
- ✅ **v2rayu.rb** - 已有配置
- ⚠️ **qv2ray.rb** - 已禁用，无需配置

#### 2. 多架构支持优化

- ✅ **flclash.rb** - 从单一 arm64 支持扩展为多架构支持

### 🎯 架构命名规范分析

经过详细分析，发现不同项目在 GitHub Releases 中使用不同的架构命名约定：

| Cask 文件 | 架构命名 | 原因 |
|-----------|----------|------|
| **clash-nyanpasu.rb** | `aarch64` / `x64` | 遵循上游项目的发布命名 |
| **clash-verge-rev.rb** | `aarch64` / `x64` | 遵循上游项目的发布命名 |
| **flclash.rb** | `arm64` / `intel` | 标准化命名（新增多架构支持） |
| **mihomo-party.rb** | `arm64` / `x64` | 遵循上游项目的发布命名 |
| **v2rayn.rb** | `arm64` / `64` | 遵循上游项目的发布命名 |
| **v2rayu.rb** | `arm64` / `64` | 遵循上游项目的发布命名 |

**重要原则**: 架构命名必须与上游项目的实际发布文件名保持一致，不能为了统一而破坏功能。

## 📝 Cask 文件标准模板

### 基础模板

```ruby
cask "app-name" do
  # 多架构支持（如果适用）
  arch arm: "arm64", intel: "intel"  # 根据上游项目调整

  version "x.y.z"
  sha256 arm:   "sha256_for_arm",     # 多架构时使用
         intel: "sha256_for_intel"   # 多架构时使用
  # 或单架构时：
  # sha256 "single_sha256"

  url "https://github.com/owner/repo/releases/download/v#{version}/app-#{version}-#{arch}.dmg"
  name "App Name"
  desc "App description"
  homepage "https://app-homepage.com/"

  # 必需：livecheck 配置
  livecheck do
    url :url
    strategy :github_latest
  end

  # 可选：自动更新
  auto_updates true

  # 可选：系统要求
  depends_on macos: ">= :catalina"

  app "App.app"
  # 或 pkg 安装：
  # pkg "app-installer.pkg"

  # 可选：卸载配置
  uninstall quit: "com.app.bundle.id"

  # 推荐：清理配置
  zap trash: [
    "~/Library/Application Support/app",
    "~/Library/Preferences/com.app.bundle.id.plist",
  ]
end
```

### 特殊情况处理

#### 1. 条件安装（如 mihomo-party.rb）

```ruby
on_catalina :or_older do
  # Catalina 及更早版本的配置
end
on_big_sur :or_newer do
  # Big Sur 及更新版本的配置
end
```

#### 2. 已禁用的应用

```ruby
disable! date: "YYYY-MM-DD", because: :discontinued
no_autobump! because: :requires_manual_review
```

#### 3. 需要特殊处理的应用

```ruby
preflight do
  system_command "xattr", args: ["-cr", "#{staged_path}/App.app"]
end
```

## 🔍 质量检查标准

### 必需项目

- [ ] **version** - 版本号
- [ ] **sha256** - 文件校验和
- [ ] **url** - 下载链接
- [ ] **name** - 应用名称
- [ ] **desc** - 应用描述
- [ ] **homepage** - 主页链接
- [ ] **livecheck** - 自动更新检查配置
- [ ] **app/pkg** - 安装目标

### 推荐项目

- [ ] **auto_updates** - 自动更新支持
- [ ] **depends_on** - 系统要求
- [ ] **zap** - 清理配置
- [ ] **多架构支持** - 如果上游提供

### 代码质量

- [ ] **缩进一致** - 使用 2 个空格
- [ ] **引号统一** - 使用双引号
- [ ] **排序规范** - 按标准顺序排列配置项
- [ ] **注释清晰** - 特殊配置需要注释说明

## 🚀 自动化检查

### GitHub Actions 集成

项目已集成以下自动化检查：

1. **语法检查** - `brew audit --cask`
2. **安装测试** - 实际安装验证
3. **自动更新** - 定期检查新版本
4. **错误处理** - 跳过已禁用的应用
5. **每周一自动运行完整验证**

### 验证脚本

```bash
# 验证所有 Cask 文件
./.github/scripts/validate-casks.sh

# 验证单个 Cask 文件
./.github/scripts/validate-casks.sh Casks/example.rb
```

### 自动修复脚本

```bash
# 查看帮助信息
./.github/scripts/fix-casks.sh --help

# 预览所有修复操作（不实际修改）
./.github/scripts/fix-casks.sh --dry-run --all

# 修复所有 Cask 文件
./.github/scripts/fix-casks.sh --all

# 修复特定文件
./.github/scripts/fix-casks.sh Casks/example.rb

# 修复并添加 zap 配置模板
./.github/scripts/fix-casks.sh --add-zap --all
```

### 本地验证命令

```bash
# 语法检查
brew audit --cask gandli/proxy/app-name

# 安装测试
brew install --cask gandli/proxy/app-name

# 样式检查
brew style Casks/app-name.rb

# Livecheck 测试
brew livecheck --cask gandli/proxy/app-name
```

## 📊 当前状态总结

### 统计信息

- **总 Cask 数量**: 10
- **已配置 livecheck**: 9 (90%)
- **多架构支持**: 6 (60%)
- **已禁用应用**: 1 (qv2ray)
- **活跃维护**: 9 (90%)

### 架构支持分布

| 架构支持类型 | 数量 | 文件 |
|-------------|------|------|
| **多架构** | 6 | clash-nyanpasu, clash-verge-rev, flclash, mihomo-party, v2rayn, v2rayu |
| **Universal** | 1 | sfm |
| **单架构** | 2 | hiddify, clashx-meta |
| **已禁用** | 1 | qv2ray |

## 🔄 维护流程

### 添加新 Cask

1. 使用标准模板创建文件
2. 确保包含 livecheck 配置
3. 测试多架构支持（如果适用）
4. 运行本地验证命令
5. 提交 PR 进行自动化测试

### 更新现有 Cask

1. 检查是否需要添加缺失的标准配置
2. 验证 livecheck 配置正确性
3. 测试架构支持
4. 更新版本和 SHA256
5. 运行自动化测试

### 定期维护

- **每周**: 检查自动更新状态
- **每月**: 审查已禁用应用状态
- **每季度**: 更新标准化指南
- **每年**: 全面审查所有 Cask 文件

## 🤝 贡献指南

### 提交 PR 时请确保

1. 遵循本文档的标准化规范
2. 包含完整的测试
3. 更新相关文档
4. 通过所有自动化检查

### 代码审查重点

1. **功能正确性** - 能否正常安装和使用
2. **标准合规性** - 是否遵循本指南
3. **安全性** - 下载链接和校验和正确性
4. **可维护性** - 代码清晰易懂

## 📄 许可证

本文档和相关标准遵循项目的 [MIT 许可证](../LICENSE)。您可以自由使用、修改和分发这些标准，但请保留版权声明。

---

*最后更新: $(date '+%Y-%m-%d')*  
*维护者: gandli*
