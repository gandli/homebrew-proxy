# 故障排除指南

本指南提供了使用Homebrew Proxy Tap安装和使用代理工具时可能遇到的常见问题的解决方案。

## 常见安装问题

### 1. 找不到Cask

**问题**: 运行`brew install gandli/proxy/<cask_name>`时出现"Cask '<cask_name>' is unavailable"错误。

**解决方案**:

- 确保您已添加我们的tap: `brew tap gandli/proxy`
- 检查cask名称拼写是否正确
- 运行`brew update`更新tap
- 查看我们的[README](../../README.md)确认cask是否存在

### 2. 校验和不匹配

**问题**: 安装时出现"SHA256 mismatch"错误。

**解决方案**:

- 这通常意味着应用程序已更新但我们的cask定义尚未更新
- 请在GitHub上[提交问题](https://github.com/gandli/homebrew-proxy/issues)报告此错误
- 临时解决方案：使用`--no-quarantine`选项安装：

```bash
brew install --cask --no-quarantine gandli/proxy/<cask_name>
```

### 3. 下载失败

**问题**: 下载应用程序时失败。

**解决方案**:

- 检查您的网络连接
- 尝试使用VPN或代理
- 如果问题持续存在，可能是下载链接已更改，请在GitHub上提交问题

### 4. 权限问题

**问题**: 安装时出现权限错误。

**解决方案**:

- 确保您有足够的权限安装应用程序
- 检查目标目录的权限
- 尝试使用`sudo`运行命令（不推荐，但在某些情况下可能需要）

## 应用程序问题

### 1. 应用程序无法启动

**问题**: 安装后应用程序无法启动。

**解决方案**:

- 检查系统安全设置，可能需要允许来自未识别开发者的应用程序
- 在"系统偏好设置" > "安全性与隐私"中允许应用程序
- 尝试重新安装应用程序：`brew reinstall --cask <cask_name>`

### 2. 应用程序崩溃

**问题**: 应用程序启动后立即崩溃。

**解决方案**:

- 检查是否有错误日志（通常在`~/Library/Logs`或`Console.app`中）
- 尝试删除应用程序的配置文件（通常在`~/Library/Preferences`或`~/Library/Application Support`中）
- 重新安装应用程序：`brew reinstall --cask <cask_name>`

### 3. 版本过旧

**问题**: 安装的应用程序版本不是最新的。

**解决方案**:

- 运行`brew update`和`brew upgrade`
- 如果问题持续存在，我们的cask可能尚未更新，请在GitHub上提交问题

## Homebrew相关问题

### 1. Homebrew更新问题

**问题**: `brew update`命令失败。

**解决方案**:

- 运行`brew doctor`检查Homebrew安装
- 按照`brew doctor`的建议修复问题
- 如果问题持续存在，尝试重置Homebrew：

```bash
cd "$(brew --repo)" && git fetch && git reset --hard origin/master
```

### 2. 权限问题

**问题**: 遇到权限错误。

**解决方案**:

- 检查Homebrew安装目录的所有权：

```bash
sudo chown -R $(whoami) $(brew --prefix)
```

- 修复权限：

```bash
chmod -R go-w "$(brew --prefix)/share/zsh"
```

## 获取帮助

如果您遇到的问题未在本指南中列出，请：

1. 查看[Homebrew官方文档](https://docs.brew.sh)
2. 在GitHub上[提交问题](https://github.com/gandli/homebrew-proxy/issues)
3. 提供详细的错误信息和您的系统信息（macOS版本、Homebrew版本等）
