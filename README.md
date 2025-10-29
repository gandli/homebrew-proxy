# 🍺 Homebrew Proxy Tap | 精选 macOS 代理工具全家桶

> 🚀 **精选 macOS 代理客户端集合** - 一键安装优质网络代理工具的 Homebrew Tap

## 📦 应用程序

| 应用名称 | 描述 | 版本 | 安装命令 | 主页 |
|---------|------|------|----------|------|
| **clash-nyanpasu** | Clash GUI based on Tauri | `1.6.1` | `brew install gandli/proxy/clash-nyanpasu` | [🔗](https://github.com/LibNyanpasu/clash-nyanpasu) |
| **Clash Verge Rev** | Continuation of Clash Verge - A Clash Meta GUI based on Tauri | `2.3.1` | `brew install gandli/proxy/clash-verge-rev` | [🔗](https://clash-verge-rev.github.io/) |
| **ClashX Meta** | Rule-based custom proxy with GUI based on Clash.Meta | `1.4.18` | `brew install gandli/proxy/clashx-meta` | [🔗](https://github.com/MetaCubeX/ClashX.Meta) |
| **FlClash** | Proxy client based on ClashMeta | `0.8.86` | `brew install gandli/proxy/flclash` | [🔗](https://github.com/chen08209/FlClash) |
| **hiddify** | Multi-platform auto-proxy client | `2.0.5` | `brew install gandli/proxy/hiddify` | [🔗](https://hiddify.com/) |
| **Mihomo Party** | Another Mihomo GUI | `1.7.6` | `brew install gandli/proxy/mihomo-party` | [🔗](https://mihomo.party/) |
| **Qv2ray** | V2Ray GUI client with extensive protocol support | `2.7.0` | `brew install gandli/proxy/qv2ray` | [🔗](https://github.com/Qv2ray/Qv2ray) |
| **SFM** | Standalone client for sing-box, the universal proxy platform | `1.11.15` | `brew install gandli/proxy/sfm` | [🔗](https://sing-box.sagernet.org/) |
| **v2rayN** | A GUI client for Windows, Linux and macOS, support Xray and sing-box and others | `7.12.7` | `brew install gandli/proxy/v2rayn` | [🔗](https://github.com/2dust/v2rayN) |
| **V2rayU** | Collection of tools to build a dedicated basic communication network | `4.2.6` | `brew install gandli/proxy/v2rayu` | [🔗](https://github.com/yanue/V2rayU) |

## 🚀 如何安装这些应用？

### 方法一：直接安装

```bash
brew install gandli/proxy/<cask_name>
```

### 方法二：先添加 Tap，再安装

```bash
brew tap gandli/proxy
brew install --cask <cask_name>
```

### 方法三：使用 Brewfile

在你的 `Brewfile` 中添加：

```ruby
tap "gandli/proxy"
cask "<cask_name>"
```

然后运行：

```bash
brew bundle
```

## 📦 Release 管理

本项目支持自动化的 Release 创建，包含所有 Casks 应用程序的最新版本信息。

### 🤖 自动创建 Release

- **GitHub Actions**：访问 [Actions 页面](../../actions/workflows/create-release.yml) 手动触发
- **定时发布**：每月1号自动创建新版本
- **版本格式**：`v年.月.日`（如：v2024.01.15）

### 🛠️ 手动创建 Release

```bash
# 使用本地脚本创建
./create-release.sh
```

## 📚 文档

- `brew help` - 查看 Homebrew 帮助
- `man brew` - 查看 Homebrew 手册
- [Homebrew 官方文档](https://docs.brew.sh) - 完整的 Homebrew 文档
- [Cask Tap 创建指南](https://docs.brew.sh/Cask-Cookbook) - Cask Tap 创建和管理指南

## 🤝 贡献

欢迎提交 Pull Request 来添加新的应用程序或改进现有的 Cask 文件！
