# 安装指南

本指南将帮助您使用Homebrew安装和管理macOS代理工具。

## 前提条件

在开始之前，请确保您已安装[Homebrew](https://brew.sh/)。如果尚未安装，请运行以下命令：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 安装方法

### 方法一：直接安装

这是最简单的方法，一条命令即可安装您需要的代理工具：

```bash
brew install gandli/proxy/<cask_name>
```

例如，安装Clash Nyanpasu：

```bash
brew install gandli/proxy/clash-nyanpasu
```

### 方法二：先添加Tap，再安装

如果您计划安装多个代理工具，可以先添加我们的tap：

```bash
# 添加tap
brew tap gandli/proxy

# 安装cask
brew install --cask <cask_name>
```

例如：

```bash
brew tap gandli/proxy
brew install --cask clash-nyanpasu
```

### 方法三：使用Brewfile

如果您使用`brew bundle`管理您的应用程序，可以在Brewfile中添加：

```ruby
tap "gandli/proxy"
cask "clash-nyanpasu"
cask "v2rayu"
# 添加更多您需要的cask
```

然后运行：

```bash
brew bundle
```

## 验证安装

安装完成后，您可以在应用程序文件夹中找到已安装的应用程序。您也可以使用以下命令验证安装：

```bash
brew list --cask | grep <cask_name>
```

## 更新应用程序

要更新已安装的应用程序，请运行：

```bash
brew update
brew upgrade
```

或者更新特定应用程序：

```bash
brew upgrade gandli/proxy/<cask_name>
```

## 卸载应用程序

要卸载应用程序，请运行：

```bash
brew uninstall --cask <cask_name>
```

## 常见问题

如果您在安装过程中遇到问题，请参阅[故障排除指南](./troubleshooting.md)。
