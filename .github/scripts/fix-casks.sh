#!/bin/bash

# Cask 文件自动修复脚本
# 用于批量修复常见的标准化问题

set -euo pipefail

# 错误处理函数
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo "❌ 脚本在第 $line_number 行发生错误 (退出码: $exit_code)" >&2

    # 清理临时文件
    cleanup_temp_files

    # 在 CI 环境中发送通知
    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        echo "::error::修复脚本执行失败，请检查日志" >&2
    fi

    exit $exit_code
}

# 清理函数
cleanup_temp_files() {
    # 清理可能的临时文件
    rm -f /tmp/fix_casks_* /tmp/backup_*
}

# 设置错误陷阱
trap 'handle_error $LINENO' ERR
trap 'cleanup_temp_files' EXIT

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 计数器
TOTAL_CASKS=0
FIXED_CASKS=0
SKIPPED_CASKS=0

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# 检查是否为 GitHub 项目
detect_github_project() {
    local cask_file="$1"
    local homepage_url
    homepage_url=$(grep "homepage" "$cask_file" | sed -n 's/.*homepage "\([^"]*\)".*/\1/p')

    if [[ "$homepage_url" =~ github\.com/([^/]+)/([^/]+) ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        return 0
    fi

    # 尝试从 URL 中提取
    local download_url
    download_url=$(grep "url " "$cask_file" | head -1 | sed -n 's/.*url "\([^"]*\)".*/\1/p')
    if [[ "$download_url" =~ github\.com/([^/]+)/([^/]+) ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        return 0
    fi

    return 1
}

# 添加 livecheck 配置
add_livecheck() {
    local cask_file="$1"
    local cask_name="$2"

    # 检查是否已有 livecheck
    if grep -q "livecheck do" "$cask_file"; then
        log_warning "$cask_name: 已有 livecheck 配置"
        return 0
    fi

    # 检查是否为禁用的应用
    if grep -q "disable!" "$cask_file"; then
        log_warning "$cask_name: 应用已禁用，跳过 livecheck 添加"
        return 0
    fi

    # 尝试检测 GitHub 项目
    local github_repo
    if github_repo=$(detect_github_project "$cask_file"); then
        log_info "$cask_name: 检测到 GitHub 项目 $github_repo"

        # 在文件末尾添加 livecheck 配置
        local temp_file
        temp_file=$(mktemp)

        # 找到最后一个 end 之前插入
        awk '
        /^end$/ && !livecheck_added {
            print "  livecheck do"
            print "    strategy :github_latest"
            print "  end"
            print ""
            livecheck_added = 1
        }
        { print }
        ' "$cask_file" > "$temp_file"

        mv "$temp_file" "$cask_file"
        log_success "$cask_name: 添加了 github_latest livecheck 配置"
        return 1
    else
        log_warning "$cask_name: 无法检测到 GitHub 项目，跳过 livecheck 添加"
        return 0
    fi
}

# 修复缩进问题
fix_indentation() {
    local cask_file="$1"
    local cask_name="$2"

    # 检查是否有不正确的缩进
    local has_issues=false

    # 检查 4 空格缩进
    if grep -q "^    [^ ]" "$cask_file"; then
        log_info "$cask_name: 修复 4 空格缩进问题"
        sed -i '' 's/^    /  /g' "$cask_file"
        has_issues=true
    fi

    # 检查 livecheck 块内的缩进
    if grep -A 10 "livecheck do" "$cask_file" | grep -q "^  [a-z]"; then
        log_info "$cask_name: 修复 livecheck 块缩进"
        # 修复 livecheck 块内容的缩进
        sed -i '' '/livecheck do/,/^  end$/ {
            /^  [a-z]/ s/^  /    /
        }' "$cask_file"
        has_issues=true
    fi

    if [[ "$has_issues" == "true" ]]; then
        log_success "$cask_name: 缩进已修复"
        return 1
    fi

    return 0
}

# 修复 HTTPS URL
fix_https_urls() {
    local cask_file="$1"
    local cask_name="$2"

    # 检查是否有 HTTP URL
    if grep "url " "$cask_file" | grep -q "http://"; then
        log_info "$cask_name: 修复 HTTP URL 为 HTTPS"

        # 替换 HTTP 为 HTTPS（仅对常见的安全站点）
        sed -i '' 's|http://github\.com|https://github.com|g' "$cask_file"
        sed -i '' 's|http://releases\.github\.com|https://releases.github.com|g' "$cask_file"
        sed -i '' 's|http://download\.github\.com|https://download.github.com|g' "$cask_file"

        log_success "$cask_name: URL 已修复为 HTTPS"
        return 1
    fi

    return 0
}

# 标准化字段顺序
standardize_field_order() {
    local cask_file="$1"
    local cask_name="$2"

    # 这是一个复杂的操作，暂时跳过
    # 可以在未来版本中实现
    return 0
}

# 添加推荐的 zap 配置模板
add_zap_template() {
    local cask_file="$1"
    local cask_name="$2"

    # 检查是否已有 zap 配置
    if grep -q "zap trash:" "$cask_file"; then
        return 0
    fi

    # 检查是否为 app 类型
    if grep -q "app " "$cask_file"; then
        local app_name
        app_name=$(grep "app " "$cask_file" | sed -n 's/.*app "\([^"]*\)".*/\1/p')

        if [[ -n "$app_name" ]]; then
            log_info "$cask_name: 添加 zap 配置模板"

            # 在最后一个 end 之前添加 zap 配置
            local temp_file
            temp_file=$(mktemp)

            awk -v app_name="$app_name" '
            /^end$/ && !zap_added {
                print ""
                print "  zap trash: ["
                print "    \"~/Library/Application Support/" app_name "\","
                print "    \"~/Library/Caches/" app_name "\","
                print "    \"~/Library/Preferences/" app_name ".plist\","
                print "  ]"
                zap_added = 1
            }
            { print }
            ' "$cask_file" > "$temp_file"

            mv "$temp_file" "$cask_file"
            log_success "$cask_name: 添加了 zap 配置模板（请手动验证路径）"
            return 1
        fi
    fi

    return 0
}

# 修复单个 Cask 文件
fix_cask() {
    local cask_file="$1"
    local cask_name
    cask_name=$(basename "$cask_file" .rb)
    local changes=0

    log_info "\n=== 修复 $cask_name ==="

    # 检查文件是否存在
    if [[ ! -f "$cask_file" ]]; then
        log_error "$cask_name: 文件不存在"
        return 1
    fi

    # 创建备份
    cp "$cask_file" "${cask_file}.backup"

    # 应用各种修复
    if add_livecheck "$cask_file" "$cask_name"; then
        ((changes++))
    fi

    if fix_indentation "$cask_file" "$cask_name"; then
        ((changes++))
    fi

    if fix_https_urls "$cask_file" "$cask_name"; then
        ((changes++))
    fi

    if standardize_field_order "$cask_file" "$cask_name"; then
        ((changes++))
    fi

    # 可选：添加 zap 配置（需要手动验证）
    if [[ "${ADD_ZAP:-false}" == "true" ]]; then
        if add_zap_template "$cask_file" "$cask_name"; then
            ((changes++))
        fi
    fi

    # 验证修复后的文件语法
    if ! ruby -c "$cask_file" >/dev/null 2>&1; then
        log_error "$cask_name: 修复后语法错误，恢复备份"
        mv "${cask_file}.backup" "$cask_file"
        return 1
    fi

    # 清理备份
    rm -f "${cask_file}.backup"

    if [[ $changes -gt 0 ]]; then
        log_success "$cask_name: 应用了 $changes 个修复 ✅"
        ((FIXED_CASKS++))
    else
        log_info "$cask_name: 无需修复"
        ((SKIPPED_CASKS++))
    fi

    return 0
}

# 生成修复报告
generate_report() {
    log_info "\n=== 修复报告 ==="
    log_info "总 Cask 数量: $TOTAL_CASKS"
    log_success "已修复: $FIXED_CASKS"
    log_warning "跳过: $SKIPPED_CASKS"

    if [[ $FIXED_CASKS -gt 0 ]]; then
        log_success "\n🎉 成功修复了 $FIXED_CASKS 个 Cask 文件！"
        log_info "\n建议操作："
        log_info "1. 运行验证脚本检查修复结果"
        log_info "2. 使用 'git diff' 查看具体变更"
        log_info "3. 测试修复后的 Cask 文件"
        log_info "4. 提交变更"
    else
        log_info "\n✨ 所有 Cask 文件都已符合标准！"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
Cask 自动修复脚本

用法: $0 [选项] [Cask文件...]

选项:
  -h, --help          显示此帮助信息
  -a, --all           修复所有 Cask 文件
  -z, --add-zap       添加 zap 配置模板（需要手动验证）
  -d, --dry-run       仅显示将要进行的修复，不实际修改文件
  -v, --verbose       显示详细输出

示例:
  $0 --all                    # 修复所有 Cask 文件
  $0 Casks/example.rb         # 修复特定文件
  $0 --add-zap --all          # 修复所有文件并添加 zap 模板
  $0 --dry-run --all          # 预览所有修复操作

修复内容:
  ✅ 添加缺少的 livecheck 配置
  ✅ 修复缩进问题（4空格 -> 2空格）
  ✅ 修复 HTTP URL 为 HTTPS
  ✅ 可选：添加 zap 配置模板

EOF
}

# 主函数
main() {
    local fix_all=false
    local dry_run=false
    local verbose=false
    local target_files=()

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -a|--all)
                fix_all=true
                shift
                ;;
            -z|--add-zap)
                export ADD_ZAP=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                export verbose  # 导出变量供其他函数使用
                shift
                ;;
            -*)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                target_files+=("$1")
                shift
                ;;
        esac
    done

    # 检查是否在正确的目录
    if [[ ! -d "Casks" ]]; then
        log_error "未找到 Casks 目录，请在项目根目录运行此脚本"
        exit 1
    fi

    log_info "开始 Cask 文件自动修复..."

    if [[ "$dry_run" == "true" ]]; then
        log_warning "DRY RUN 模式：仅显示将要进行的操作，不会实际修改文件"
    fi

    # 确定要处理的文件
    local files_to_process=()

    if [[ "$fix_all" == "true" ]]; then
        while IFS= read -r -d '' file; do
            files_to_process+=("$file")
        done < <(find Casks -name "*.rb" -print0)
    elif [[ ${#target_files[@]} -gt 0 ]]; then
        files_to_process=("${target_files[@]}")
    else
        log_error "请指定要修复的文件或使用 --all 选项"
        show_help
        exit 1
    fi

    TOTAL_CASKS=${#files_to_process[@]}
    log_info "将处理 $TOTAL_CASKS 个 Cask 文件"

    # 处理每个文件
    for cask_file in "${files_to_process[@]}"; do
        if [[ -f "$cask_file" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                log_info "[DRY RUN] 将修复: $cask_file"
                ((SKIPPED_CASKS++))
            else
                fix_cask "$cask_file"
            fi
        else
            log_error "文件不存在: $cask_file"
        fi
    done

    # 生成报告
    generate_report

    if [[ "$dry_run" == "true" ]]; then
        log_info "\n要实际执行修复，请移除 --dry-run 选项"
    fi
}

# 运行主函数
main "$@"
