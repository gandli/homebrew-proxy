# Cask创建指南

本指南将帮助您为Homebrew Proxy Tap创建和维护高质量的Cask文件。

## Cask基础知识

Cask是Homebrew的一种特殊公式，用于安装macOS应用程序。每个Cask文件都是一个Ruby脚本，定义了应用程序的下载、安装和配置方式。

## Cask文件结构

一个典型的Cask文件结构如下：

```ruby
cask "application-name" do
  version "1.2.3"
  sha256 "abcdef123456..."

  url "https://example.com/download/app-#{version}.dmg"
  name "Application Name"
  desc "Brief description of the application"
  homepage "https://example.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "Application.app"

  zap trash: [
    "~/Library/Application Support/application-name",
    "~/Library/Preferences/com.example.application.plist",
  ]
end
```

## 创建新Cask

### 步骤1：确认应用程序信息

在创建Cask之前，请收集以下信息：

- 应用程序名称
- 最新版本号
- 下载URL
- SHA256校验和
- 应用程序描述
- 主页URL
- 应用程序安装路径
- 应用程序数据文件位置（用于zap stanza）

### 步骤2：使用模板创建Cask

使用我们的Makefile命令创建新Cask：

```bash
make new-cask NAME=application-name
```

这将在`Casks/`目录中创建一个基本的Cask模板文件。

### 步骤3：编辑Cask文件

编辑生成的模板，填写正确的信息：

1. **版本号**：使用最新的稳定版本

   ```ruby
   version "1.2.3"
   ```

2. **SHA256校验和**：计算下载文件的SHA256

   ```bash
   # 下载文件
   curl -L "https://example.com/download/app-1.2.3.dmg" -o app.dmg

   # 计算SHA256
   shasum -a 256 app.dmg
   ```

   然后更新Cask文件：

   ```ruby
   sha256 "calculated_sha256_value"
   ```

3. **下载URL**：指定下载链接，使用`#{version}`变量引用版本号

   ```ruby
   url "https://example.com/download/app-#{version}.dmg"
   ```

4. **名称和描述**：提供准确的应用程序名称和简洁的描述

   ```ruby
   name "Application Name"
   desc "Brief description of the application"
   ```

5. **主页**：提供官方主页URL

   ```ruby
   homepage "https://example.com/"
   ```

6. **Livecheck**：配置自动版本检查

   ```ruby
   livecheck do
     url :homepage  # 或特定的版本检查URL
     strategy :page_match  # 或其他适当的策略
     regex(/version (\d+\.\d+\.\d+)/i)
   end
   ```

7. **安装指令**：指定如何安装应用程序

   ```ruby
   app "Application.app"  # 对于.app文件
   # 或
   pkg "Install.pkg"  # 对于.pkg安装程序
   ```

8. **Zap指令**：指定卸载时要删除的文件

   ```ruby
   zap trash: [
     "~/Library/Application Support/application-name",
     "~/Library/Preferences/com.example.application.plist",
   ]
   ```

### 步骤4：验证Cask

验证您的Cask是否符合Homebrew标准：

```bash
make validate-file FILE=Casks/application-name.rb
```

修复任何报告的问题。

### 步骤5：测试安装

测试Cask是否可以正确安装：

```bash
brew install --cask ./Casks/application-name.rb
```

确保应用程序安装正确并可以启动。

### 步骤6：提交Cask

按照[贡献指南](./contributing.md)提交您的Cask。

## Cask分类

我们按类型将Cask组织到子目录中：

- `Casks/clash/` - Clash相关工具
- `Casks/v2ray/` - V2Ray相关工具
- `Casks/others/` - 其他代理工具

请将您的Cask放在适当的子目录中。

## 高级Cask技巧

### 条件安装

对于需要根据macOS版本执行不同操作的应用程序：

```ruby
if MacOS.version >= :big_sur
  # Big Sur及更高版本的操作
else
  # 较旧版本的操作
end
```

### 多架构支持

对于提供不同架构版本的应用程序：

```ruby
arch arm: {
  url "https://example.com/download/app-arm-#{version}.dmg",
  sha256 "arm_sha256_value"
},
     intel: {
       url "https://example.com/download/app-intel-#{version}.dmg",
       sha256 "intel_sha256_value"
     }
```

### 复杂的版本号

对于具有复杂版本号的应用程序：

```ruby
version "1.2.3,45:6789"

livecheck do
  url :url
  strategy :extract_plist
  key "CFBundleShortVersionString"
end
```

## 常见问题

### 1. SHA256不匹配

**问题**：安装时出现SHA256不匹配错误。

**解决方案**：

- 重新下载应用程序并计算SHA256
- 确认下载URL是否正确
- 检查应用程序是否已更新

### 2. Livecheck不工作

**问题**：自动版本检查不工作。

**解决方案**：

- 检查URL是否正确
- 调整正则表达式以匹配版本号
- 尝试不同的livecheck策略

### 3. 应用程序无法安装

**问题**：应用程序安装失败。

**解决方案**：

- 检查安装stanza是否正确
- 验证应用程序包结构
- 确认应用程序与当前macOS版本兼容

## 最佳实践

1. **使用版本变量**：在URL中使用`#{version}`引用版本号
2. **提供完整的zap stanza**：包括所有应用程序数据文件
3. **添加有用的描述**：简洁但信息丰富
4. **配置livecheck**：便于自动检测更新
5. **遵循命名约定**：使用小写和连字符
6. **测试安装和卸载**：确保完整的用户体验

## 资源

- [Homebrew Cask文档](https://docs.brew.sh/Cask-Cookbook)
- [Cask语言参考](https://docs.brew.sh/Cask-Language-Reference)
- [Livecheck参考](https://docs.brew.sh/Cask-Language-Reference#stanza-livecheck)
