#!/bin/bash

# Cask 文件标准化验证脚本
# 用于检查所有 Cask 文件是否符合项目标准

set -euo pipefail

# 错误处理函数
# shellcheck disable=SC2317  # 函数通过 trap 间接调用
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo "❌ 脚本在第 $line_number 行发生错误 (退出码: $exit_code)" >&2

    # 清理临时文件
    cleanup_temp_files

    # 在 CI 环境中发送通知
    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        echo "::error::验证脚本执行失败，请检查日志" >&2
    fi

    exit "$exit_code"
}

# 清理函数
# shellcheck disable=SC2317  # 函数通过 trap 间接调用
cleanup_temp_files() {
    # 清理可能的临时文件
    rm -f /tmp/validate_casks_*
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
PASSED_CASKS=0
FAILED_CASKS=0
WARNING_CASKS=0
TOTAL_WARNINGS=0

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    if [[ "${verbose:-false}" == "true" ]]; then
        echo "[DEBUG] $1" >&2
    fi
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

log_debug() {
    if [[ "${verbose:-false}" == "true" ]]; then
        echo "[DEBUG] $1" >&2
    fi
}

# 检查 livecheck 配置
check_livecheck() {
    local cask_file="$1"
    local cask_name="$2"

    # 跳过已禁用的应用
    if grep -q "disable!" "$cask_file"; then
        log_info "$cask_name: 已禁用，跳过 livecheck 检查"
        return 0
    fi

    if grep -q "livecheck do" "$cask_file"; then
        log_success "$cask_name: livecheck 配置存在"

        # 检查是否使用推荐的 github_latest 策略
        if grep -q "strategy :github_latest" "$cask_file"; then
            log_success "$cask_name: 使用推荐的 github_latest 策略"
        else
            log_warning "$cask_name: 未使用推荐的 github_latest 策略"
            ((WARNING_CASKS++))
        fi
        return 0
    else
        log_error "$cask_name: 缺少 livecheck 配置"
        return 1
    fi
}

# 检查架构支持
check_architecture() {
    local cask_file="$1"
    local cask_name="$2"
    local warnings=0

    if grep -q "arch arm:" "$cask_file"; then
        log_success "$cask_name: 支持多架构"

        # 检查架构命名一致性
        local arch_line
        arch_line=$(grep "arch arm:" "$cask_file")
        log_info "$cask_name: 架构配置 - $arch_line"

        # 检查是否有对应的 sha256 配置
        if grep -q "sha256 arm:" "$cask_file"; then
            log_success "$cask_name: 多架构 SHA256 配置正确"
        else
            log_warning "$cask_name: 多架构但缺少对应的 SHA256 配置"
            ((warnings++))
        fi
    else
        # 检查是否为 universal 构建
        if grep -q "universal" "$cask_file"; then
            log_success "$cask_name: 使用 universal 构建"
        else
            log_warning "$cask_name: 单架构支持，考虑添加多架构支持"
            ((warnings++))
        fi
    fi

    return $warnings
}

# 检查必需字段
check_required_fields() {
    local cask_file="$1"
    local cask_name="$2"
    local errors=0

    # 必需字段列表
    local required_fields=("version" "sha256" "url" "name" "desc" "homepage")

    for field in "${required_fields[@]}"; do
        if grep -q "$field" "$cask_file"; then
            log_success "$cask_name: $field 字段存在"
        else
            log_error "$cask_name: 缺少必需字段 $field"
            ((errors++))
        fi
    done

    # 检查安装目标（app 或 pkg）
    if grep -q "app \|pkg " "$cask_file"; then
        log_success "$cask_name: 安装目标配置正确"
    else
        log_error "$cask_name: 缺少安装目标配置 (app 或 pkg)"
        ((errors++))
    fi

    return $errors
}

# 检查代码质量
check_code_quality() {
    local cask_file="$1"
    local cask_name="$2"
    local warnings=0

    # 检查缩进（应该使用 2 个空格）
    if grep -q "^    [^ ]" "$cask_file"; then
        log_warning "$cask_name: 检测到 4 空格缩进，建议使用 2 空格"
        ((warnings++))
    fi

    # 检查是否有 zap 配置（推荐）
    if grep -q "zap trash:" "$cask_file"; then
        log_success "$cask_name: 包含清理配置 (zap)"
    else
        log_warning "$cask_name: 建议添加清理配置 (zap)"
        ((warnings++))
    fi

    # 检查 URL 是否使用 HTTPS
    if grep "url " "$cask_file" | grep -q "https://"; then
        log_success "$cask_name: 使用 HTTPS 下载链接"
    else
        log_warning "$cask_name: 建议使用 HTTPS 下载链接"
        ((warnings++))
    fi

    return $warnings
}

# 验证单个 Cask 文件
validate_cask() {
    local cask_file="$1"
    local cask_name
    cask_name=$(basename "$cask_file" .rb)
    local errors=0
    local warnings=0

    log_info "\n=== 验证 $cask_name ==="
    log_debug "验证文件: $cask_file"

    # 检查文件是否存在
    if [[ ! -f "$cask_file" ]]; then
        log_error "$cask_name: 文件不存在"
        return 1
    fi

    # 检查必需字段
    if ! check_required_fields "$cask_file" "$cask_name"; then
        ((errors++))
    fi

    # 检查 livecheck 配置
    if ! check_livecheck "$cask_file" "$cask_name"; then
        ((errors++))
    fi

    # 检查架构支持
    check_architecture "$cask_file" "$cask_name"
    local arch_warnings=$?
    ((warnings += arch_warnings))

    # 检查代码质量
    check_code_quality "$cask_file" "$cask_name"
    local quality_warnings=$?
    ((warnings += quality_warnings))

    # 运行 brew audit（如果可用）
    if command -v brew >/dev/null 2>&1; then
        log_info "$cask_name: 运行 brew audit 检查"
        if brew audit --cask "$cask_file" 2>/dev/null; then
            log_success "$cask_name: brew audit 检查通过"
        else
            log_warning "$cask_name: brew audit 检查有警告"
            ((warnings++))
        fi
    fi

    # 统计结果
    if [[ $errors -eq 0 ]]; then
        if [[ $warnings -eq 0 ]]; then
            log_success "$cask_name: 验证完全通过 ✅"
            ((PASSED_CASKS++))
        else
            log_warning "$cask_name: 验证通过但有 $warnings 个警告 ⚠️"
            ((WARNING_CASKS++))
        fi
    else
        log_error "$cask_name: 验证失败，有 $errors 个错误 ❌"
        ((FAILED_CASKS++))
    fi

    # 累计警告总数
    ((TOTAL_WARNINGS += warnings))

    return $errors
}

# 生成验证报告
generate_report() {
    log_info "\n=== 验证报告 ==="
    log_info "总 Cask 数量: $TOTAL_CASKS"
    log_success "完全通过: $PASSED_CASKS"
    log_warning "有警告的 Cask: $WARNING_CASKS (总警告数: $TOTAL_WARNINGS)"
    log_error "验证失败: $FAILED_CASKS"

    local success_rate=$(((PASSED_CASKS + WARNING_CASKS) * 100 / TOTAL_CASKS))
    log_info "成功率: ${success_rate}%"

    if [[ $FAILED_CASKS -eq 0 ]]; then
        log_success "\n🎉 所有 Cask 文件验证通过！"
        return 0
    else
        log_error "\n❌ 有 $FAILED_CASKS 个 Cask 文件验证失败"
        return 1
    fi
}

# 主函数
main() {
    log_info "开始验证 Cask 文件标准化..."

    # 检查是否在正确的目录
    if [[ ! -d "Casks" ]]; then
        log_error "未找到 Casks 目录，请在项目根目录运行此脚本"
        exit 1
    fi

    # 统计总数
    TOTAL_CASKS=$(find Casks -name "*.rb" | wc -l | tr -d ' ')
    log_info "发现 $TOTAL_CASKS 个 Cask 文件"

    # 验证每个 Cask 文件
    local overall_result=0
    for cask_file in Casks/*.rb; do
        if [[ -f "$cask_file" ]]; then
            if ! validate_cask "$cask_file"; then
                overall_result=1
            fi
        fi
    done

    # 生成报告
    if ! generate_report; then
        overall_result=1
    fi

    exit $overall_result
}

# 运行主函数
main "$@"
