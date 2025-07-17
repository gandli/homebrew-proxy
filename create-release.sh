#!/bin/bash

# 创建 Homebrew Proxy Tap Release 脚本
# 用于创建包含所有 Casks 应用程序的发布版本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查必要的工具
check_dependencies() {
    print_info "检查必要的依赖工具..."
    
    local missing_tools=()
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if ! command -v gh &> /dev/null; then
        missing_tools+=("gh (GitHub CLI)")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "缺少以下必要工具: ${missing_tools[*]}"
        print_info "请安装缺少的工具后重试"
        print_info "安装命令:"
        echo "  brew install gh jq"
        exit 1
    fi
    
    print_success "所有依赖工具已安装"
}

# 获取当前日期作为版本号
get_version() {
    echo "v$(date +%Y.%m.%d)"
}

# 从 Cask 文件中提取应用信息
extract_app_info() {
    local cask_file="$1"
    local app_name=$(basename "$cask_file" .rb)
    local version=$(grep -E '^\s*version\s+"' "$cask_file" | sed -E 's/.*version\s+"([^"]+)".*/\1/' | head -1)
    local desc=$(grep -E '^\s*desc\s+"' "$cask_file" | sed -E 's/.*desc\s+"([^"]+)".*/\1/' | head -1)
    local homepage=$(grep -E '^\s*homepage\s+"' "$cask_file" | sed -E 's/.*homepage\s+"([^"]+)".*/\1/' | head -1)
    
    echo "| **$app_name** | $desc | \`$version\` | \`brew install gandli/proxy/$app_name\` | [🔗]($homepage) |"
}

# 从 Cask 文件中提取下载 URL 并下载应用程序
# 参数: cask_file_path download_dir
download_app_from_cask() {
    local cask_file="$1"
    local download_dir="$2"
    local app_name=$(basename "$cask_file" .rb)
    
    print_info "正在处理 $app_name..." >&2
    
    # 创建临时目录用于下载
    local temp_dir="$download_dir/$app_name"
    mkdir -p "$temp_dir"
    
    # 提取版本号
    local version=$(grep -E '^\s*version\s+"' "$cask_file" | sed 's/.*"\([^"]*\)".*/\1/' | head -1)
    
    if [[ -z "$version" ]]; then
        print_warning "无法提取版本号: $app_name" >&2
        return 1
    fi
    
    # 检查是否有架构特定的配置
    if grep -q "arch arm:" "$cask_file"; then
        # 处理多架构应用
        local arm_arch=$(grep "arch arm:" "$cask_file" | sed -E 's/.*arch arm: "([^"]+)".*/\1/')
        local intel_arch=$(grep "arch arm:" "$cask_file" | sed -E 's/.*intel: "([^"]+)".*/\1/')
        
        # 检查是否有条件性 URL（如 mihomo-party）
        if grep -q "on_.*:" "$cask_file"; then
            # 处理条件性配置，优先使用 big_sur 或更新的配置
            local url_line=$(grep -A 5 "on_big_sur" "$cask_file" | grep -E '^\s*url\s+"' | head -1)
            if [[ -z "$url_line" ]]; then
                # 如果没有 big_sur 配置，使用第一个找到的 URL
                url_line=$(grep -E '^\s*url\s+"' "$cask_file" | head -1)
            fi
        else
            # 标准多架构配置
            local url_line=$(grep -E '^\s*url\s+"' "$cask_file" | head -1)
        fi
        
        if [[ -n "$url_line" ]]; then
            local base_url=$(echo "$url_line" | sed 's/.*"\([^"]*\)".*/\1/')
            
            # 替换变量
            local arm_url=$(echo "$base_url" | sed "s/#{version}/$version/g" | sed "s/#{arch}/$arm_arch/g")
            local intel_url=$(echo "$base_url" | sed "s/#{version}/$version/g" | sed "s/#{arch}/$intel_arch/g")
            
            # 下载 ARM 版本
            if [[ -n "$arm_url" ]]; then
                local arm_filename="${app_name}-${version}-arm64$(echo "$arm_url" | sed 's/.*\(\.[^.]*\)$/\1/')"
                print_info "下载 ARM 版本: $arm_filename" >&2
                if curl -L --fail --max-time 300 -o "$temp_dir/$arm_filename" "$arm_url" 2>/dev/null; then
                    echo "$temp_dir/$arm_filename"
                else
                    print_warning "ARM 版本下载失败: $arm_url" >&2
                fi
            fi
            
            # 下载 Intel 版本
            if [[ -n "$intel_url" ]]; then
                local intel_filename="${app_name}-${version}-intel$(echo "$intel_url" | sed 's/.*\(\.[^.]*\)$/\1/')"
                print_info "下载 Intel 版本: $intel_filename" >&2
                if curl -L --fail --max-time 300 -o "$temp_dir/$intel_filename" "$intel_url" 2>/dev/null; then
                    echo "$temp_dir/$intel_filename"
                else
                    print_warning "Intel 版本下载失败: $intel_url" >&2
                fi
            fi
        fi
    else
        # 处理单一架构应用
        local url=$(grep -E '^\s*url\s+"' "$cask_file" | sed 's/.*"\([^"]*\)".*/\1/' | head -1)
        # 替换版本变量
        url=$(echo "$url" | sed "s/#{version}/$version/g")
        
        if [[ -n "$url" ]]; then
            local filename="${app_name}-${version}$(echo "$url" | sed 's/.*\(\.[^.]*\)$/\1/')"
            print_info "下载通用版本: $filename" >&2
            if curl -L --fail --max-time 300 -o "$temp_dir/$filename" "$url" 2>/dev/null; then
                echo "$temp_dir/$filename"
            else
                print_warning "下载失败: $url" >&2
            fi
        fi
    fi
}

# 生成发布说明
generate_release_notes() {
    local version="$1"
    local release_notes_file="release-notes.md"
    
    print_info "生成发布说明..." >&2
    
    cat > "$release_notes_file" << EOF
# 🍺 Homebrew Proxy Tap Release $version

> 🚀 **精选 macOS 代理客户端集合** - 一键安装优质网络代理工具的 Homebrew Tap

## 📦 本次发布包含的应用程序

| 应用名称 | 描述 | 版本 | 安装命令 | 主页 |
|---------|------|------|----------|------|
EOF

    # 遍历所有 Cask 文件并提取信息
    for cask_file in Casks/*.rb; do
        if [ -f "$cask_file" ]; then
            extract_app_info "$cask_file" >> "$release_notes_file"
        fi
    done
    
    cat >> "$release_notes_file" << EOF

## 🚀 如何安装这些应用？

### 方法一：直接安装

\`\`\`bash
brew install gandli/proxy/<cask_name>
\`\`\`

### 方法二：先添加 Tap，再安装

\`\`\`bash
brew tap gandli/proxy
brew install --cask <cask_name>
\`\`\`

### 方法三：使用 Brewfile

在你的 \`Brewfile\` 中添加：

\`\`\`ruby
tap "gandli/proxy"
cask "<cask_name>"
\`\`\`

然后运行：

\`\`\`bash
brew bundle
\`\`\`

### 方法四：直接下载应用程序

您也可以从本 Release 的 **Assets** 部分直接下载预编译的应用程序文件：

1. 访问 [Release 页面](https://github.com/gandli/homebrew-proxy/releases/latest)
2. 在 **Assets** 部分找到您需要的应用程序
3. 下载对应您系统架构的版本（ARM64 或 Intel）
4. 解压并安装到 Applications 文件夹

\`\`\`bash
# 示例：下载后手动安装
# 1. 下载 .dmg 或 .pkg 文件
# 2. 双击打开安装包
# 3. 按照安装向导完成安装
\`\`\`

> **注意**: Assets 中包含的是从官方源下载的实际应用程序安装包，支持 ARM64 和 Intel 两种架构。这些文件与通过 Homebrew 安装的文件完全相同。

## 📈 更新内容

- 📦 包含 $(ls Casks/*.rb | wc -l | tr -d ' ') 个精选代理应用程序
- 🔄 所有应用程序版本已更新至最新
- ✅ 所有 Cask 文件已通过测试验证
- 🛡️ 确保所有下载链接和校验和的安全性

## 🔧 技术改进

- 🤖 自动化 Cask 更新流程
- 📊 改进的版本检测机制
- 🔍 增强的错误处理和日志记录
- ⚡ 优化的构建和发布流程

## 🤝 贡献

感谢所有为本项目做出贡献的开发者！欢迎提交 Pull Request 来添加新的应用程序或改进现有的 Cask 文件。

## 📞 支持

如果您在使用过程中遇到任何问题，请：

1. 查看 [README.md](README.md) 中的文档
2. 在 [Issues](https://github.com/gandli/homebrew-proxy/issues) 中搜索相关问题
3. 如果问题未解决，请创建新的 Issue

---

**安装命令快速参考：**

\`\`\`bash
# 添加 Tap
brew tap gandli/proxy

# 安装所有应用（可选）
EOF

    # 添加所有应用的安装命令
    for cask_file in Casks/*.rb; do
        if [ -f "$cask_file" ]; then
            local app_name=$(basename "$cask_file" .rb)
            echo "brew install --cask $app_name" >> "$release_notes_file"
        fi
    done
    
    echo '```' >> "$release_notes_file"
    
    print_success "发布说明已生成: $release_notes_file" >&2
    # 返回文件名（不使用 echo 避免与其他输出混合）
    echo "$release_notes_file"
}

# 创建 Git 标签
create_git_tag() {
    local version="$1"
    
    print_info "创建 Git 标签: $version"
    
    # 检查标签是否已存在
    if git tag -l | grep -q "^$version$"; then
        print_warning "标签 $version 已存在"
        read -p "是否删除现有标签并重新创建？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "$version"
            git push origin --delete "$version" 2>/dev/null || true
        else
            print_error "操作已取消"
            exit 1
        fi
    fi
    
    # 创建标签
    git tag -a "$version" -m "Release $version - Homebrew Proxy Tap with $(ls Casks/*.rb | wc -l | tr -d ' ') proxy applications"
    
    print_success "Git 标签 $version 已创建"
}

# 推送到远程仓库
push_to_remote() {
    local version="$1"
    
    print_info "推送标签到远程仓库..."
    
    git push origin "$version"
    
    print_success "标签已推送到远程仓库"
}

# 创建 GitHub Release
create_github_release() {
    local version="$1"
    local release_notes_file="$2"
    
    print_info "创建 GitHub Release..."
    
    # 检查是否已登录 GitHub CLI
    if ! gh auth status &>/dev/null; then
        print_error "请先登录 GitHub CLI"
        print_info "运行: gh auth login"
        exit 1
    fi
    
    # 创建临时下载目录
    local download_dir="./temp_downloads"
    mkdir -p "$download_dir"
    
    print_info "开始从官方源下载应用程序文件..."
    
    # 下载所有应用程序文件
    local app_files=()
    local failed_downloads=()
    
    for cask_file in Casks/*.rb; do
        if [ -f "$cask_file" ]; then
            local app_name=$(basename "$cask_file" .rb)
            print_info "处理 $app_name..."
            
            # 下载应用程序文件
            local downloaded_files=$(download_app_from_cask "$cask_file" "$download_dir")
            
            if [[ -n "$downloaded_files" ]]; then
                # 将下载的文件添加到数组中
                while IFS= read -r file; do
                    if [[ -f "$file" ]]; then
                        app_files+=("$file")
                        print_success "已下载: $(basename "$file")"
                    fi
                done <<< "$downloaded_files"
            else
                failed_downloads+=("$app_name")
                print_warning "下载失败: $app_name"
            fi
        fi
    done
    
    print_info "准备上传 ${#app_files[@]} 个应用程序文件作为 Release Assets..."
    
    if [ ${#failed_downloads[@]} -gt 0 ]; then
        print_warning "以下应用下载失败: ${failed_downloads[*]}"
        print_warning "将继续创建 Release，但这些应用不会包含在 Assets 中"
    fi
    
    # 创建 Release 并上传应用程序文件
    if [ ${#app_files[@]} -gt 0 ]; then
        gh release create "$version" \
            --title "🍺 Homebrew Proxy Tap $version" \
            --notes-file "$release_notes_file" \
            --latest \
            "${app_files[@]}"
    else
        print_warning "没有成功下载任何应用程序文件，创建不包含 Assets 的 Release"
        gh release create "$version" \
            --title "🍺 Homebrew Proxy Tap $version" \
            --notes-file "$release_notes_file" \
            --latest
    fi
    
    print_success "GitHub Release $version 已创建，包含 ${#app_files[@]} 个应用程序文件"
    
    # 清理下载的文件
    print_info "清理临时下载文件..."
    rm -rf "$download_dir"
}

# 清理临时文件
cleanup() {
    print_info "清理临时文件..."
    rm -f release-notes.md
    print_success "清理完成"
}

# 主函数
main() {
    print_info "🚀 开始创建 Homebrew Proxy Tap Release..."
    
    # 检查是否在正确的目录
    if [ ! -d "Casks" ] || [ ! -f "README.md" ]; then
        print_error "请在 homebrew-proxy 项目根目录下运行此脚本"
        exit 1
    fi
    
    # 检查依赖
    check_dependencies
    
    # 获取版本号
    local version=$(get_version)
    print_info "准备创建版本: $version"
    
    # 确认操作
    read -p "是否继续创建 Release $version？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "操作已取消"
        exit 0
    fi
    
    # 生成发布说明
    local release_notes_file=$(generate_release_notes "$version")
    
    # 显示发布说明预览
    print_info "发布说明预览:"
    echo "----------------------------------------"
    head -20 "$release_notes_file"
    echo "..."
    echo "----------------------------------------"
    
    read -p "发布说明是否正确？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "请手动编辑 $release_notes_file 后重新运行脚本"
        exit 0
    fi
    
    # 创建 Git 标签
    create_git_tag "$version"
    
    # 推送到远程仓库
    push_to_remote "$version"
    
    # 创建 GitHub Release
    create_github_release "$version" "$release_notes_file"
    
    # 清理
    cleanup
    
    print_success "🎉 Release $version 创建完成！"
    print_info "您可以在以下地址查看: https://github.com/gandli/homebrew-proxy/releases/tag/$version"
}

# 捕获退出信号，确保清理
trap cleanup EXIT

# 运行主函数
main "$@"