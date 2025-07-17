#!/bin/bash

# 开发工具集合脚本
# 作者: homebrew-proxy 项目
# 用途: 提供统一的开发工具入口
# 用法: ./dev-tools.sh [command] [options]

set -euo pipefail

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# 显示帮助信息
show_help() {
    cat << EOF
${CYAN}🛠️  Homebrew Proxy 开发工具集${NC}

${YELLOW}用法:${NC}
  ./dev-tools.sh [command] [options]

${YELLOW}可用命令:${NC}
  ${GREEN}validate${NC}     验证 Cask 文件
    --all          验证所有 Cask 文件
    --file <file>  验证指定文件
    --fix          验证后自动修复问题

  ${GREEN}fix${NC}          修复 Cask 文件格式问题
    --all          修复所有 Cask 文件
    --file <file>  修复指定文件
    --dry-run      仅显示需要修复的内容，不实际修改

  ${GREEN}test${NC}         运行项目测试
    --unit         运行单元测试
    --integration  运行集成测试
    --all          运行所有测试

  ${GREEN}setup${NC}        设置开发环境
    --deps         安装依赖
    --hooks        设置 Git hooks
    --config       配置开发环境

  ${GREEN}clean${NC}        清理项目
    --cache        清理缓存文件
    --temp         清理临时文件
    --all          清理所有生成文件

  ${GREEN}lint${NC}         代码检查和格式化
    --check        仅检查，不修改
    --fix          自动修复可修复的问题

  ${GREEN}quality${NC}      代码质量检查
    --full         运行完整质量检查
    --ruby         检查 Ruby 代码
    --shell        检查 Shell 脚本

  ${GREEN}release${NC}      发布相关操作
    --prepare      准备发布
    --changelog    生成变更日志
    --tag          创建发布标签

  ${GREEN}stats${NC}        项目统计信息
    --casks        Cask 文件统计
    --commits      提交统计
    --contributors 贡献者统计

  ${GREEN}help${NC}         显示此帮助信息

${YELLOW}示例:${NC}
  ./dev-tools.sh validate --all
  ./dev-tools.sh fix --file Casks/clash-nyanpasu.rb
  ./dev-tools.sh test --unit
  ./dev-tools.sh setup --deps
  ./dev-tools.sh clean --temp

${YELLOW}环境变量:${NC}
  ${CYAN}DEBUG${NC}=1        启用调试模式
  ${CYAN}VERBOSE${NC}=1      启用详细输出
  ${CYAN}DRY_RUN${NC}=1      仅显示操作，不实际执行

EOF
}

# 验证 Cask 文件
validate_casks() {
    local validate_script="$SCRIPT_DIR/validate-casks.sh"

    if [[ ! -f "$validate_script" ]]; then
        log_error "验证脚本不存在: $validate_script"
        return 1
    fi

    log_step "运行 Cask 验证..."

    case "${1:-}" in
        --all)
            "$validate_script" --all
            ;;
        --file)
            if [[ -z "${2:-}" ]]; then
                log_error "请指定要验证的文件"
                return 1
            fi
            "$validate_script" "$2"
            ;;
        --fix)
            "$validate_script" --all
            if ! "$validate_script" --all; then
                log_warning "发现问题，尝试自动修复..."
                fix_casks --all
            fi
            ;;
        *)
            "$validate_script" --all
            ;;
    esac
}

# 修复 Cask 文件
fix_casks() {
    local fix_script="$SCRIPT_DIR/fix-casks.sh"

    if [[ ! -f "$fix_script" ]]; then
        log_error "修复脚本不存在: $fix_script"
        return 1
    fi

    log_step "运行 Cask 修复..."

    case "${1:-}" in
        --all)
            "$fix_script" --all
            ;;
        --file)
            if [[ -z "${2:-}" ]]; then
                log_error "请指定要修复的文件"
                return 1
            fi
            "$fix_script" "$2"
            ;;
        --dry-run)
            log_info "干运行模式：仅显示需要修复的内容"
            DRY_RUN=1 "$fix_script" --all
            ;;
        *)
            "$fix_script" --all
            ;;
    esac
}

# 运行测试
run_tests() {
    log_step "运行项目测试..."

    case "${1:-}" in
        --unit)
            log_info "运行单元测试..."
            # 这里可以添加单元测试逻辑
            validate_casks --all
            ;;
        --integration)
            log_info "运行集成测试..."
            # 这里可以添加集成测试逻辑
            if command -v brew >/dev/null 2>&1; then
                log_info "测试 Homebrew 集成..."
                brew tap --list-pinned
            fi
            ;;
        --all|*)
            log_info "运行所有测试..."
            run_tests --unit
            run_tests --integration
            ;;
    esac
}

# 设置开发环境
setup_environment() {
    log_step "设置开发环境..."

    case "${1:-}" in
        --deps)
            log_info "检查和安装依赖..."
            if ! command -v brew >/dev/null 2>&1; then
                log_error "请先安装 Homebrew: https://brew.sh"
                return 1
            fi
            log_success "Homebrew 已安装"
            ;;
        --hooks)
            log_info "设置 Git hooks..."
            # 创建 pre-commit hook
            cat > "$PROJECT_ROOT/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook: 验证 Cask 文件
echo "🔍 运行 pre-commit 检查..."
cd "$(git rev-parse --show-toplevel)"
./.github/scripts/dev-tools.sh validate --all
EOF
            chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"
            log_success "Git hooks 设置完成"
            ;;
        --config)
            log_info "配置开发环境..."
            # 创建 .editorconfig
            if [[ ! -f "$PROJECT_ROOT/.editorconfig" ]]; then
                cat > "$PROJECT_ROOT/.editorconfig" << 'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.rb]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[*.yml]
indent_size = 2
EOF
                log_success "创建 .editorconfig"
            fi
            ;;
        *)
            setup_environment --deps
            setup_environment --hooks
            setup_environment --config
            ;;
    esac
}

# 清理项目
clean_project() {
    log_step "清理项目..."

    case "${1:-}" in
        --cache)
            log_info "清理缓存文件..."
            find "$PROJECT_ROOT" -name ".DS_Store" -delete 2>/dev/null || true
            log_success "缓存清理完成"
            ;;
        --temp)
            log_info "清理临时文件..."
            find "$PROJECT_ROOT" -name "*.tmp" -delete 2>/dev/null || true
            find "$PROJECT_ROOT" -name "*.bak" -delete 2>/dev/null || true
            log_success "临时文件清理完成"
            ;;
        --all|*)
            clean_project --cache
            clean_project --temp
            ;;
    esac
}

# 代码检查和格式化
lint_code() {
    log_step "代码检查和格式化..."

    case "${1:-}" in
        --check)
            log_info "检查代码格式..."
            validate_casks --all
            ;;
        --fix)
            log_info "自动修复代码格式..."
            fix_casks --all
            ;;
        *)
            lint_code --check
            ;;
    esac
}

# 代码质量检查
quality_check() {
    log_step "代码质量检查..."

    case "${1:-}" in
        --full)
            run_full_quality_check
            ;;
        --ruby)
            check_ruby_quality
            ;;
        --shell)
            check_shell_quality
            ;;
        *)
            run_full_quality_check
            ;;
    esac
}

# 运行完整质量检查
run_full_quality_check() {
    local has_errors=false

    log_info "运行完整代码质量检查..."

    # 检查 Ruby 代码
    if ! check_ruby_quality; then
        has_errors=true
    fi

    # 检查 Shell 脚本
    if ! check_shell_quality; then
        has_errors=true
    fi

    # 检查 YAML 文件
    if ! check_yaml_quality; then
        has_errors=true
    fi

    # 检查 Markdown 文件
    if ! check_markdown_quality; then
        has_errors=true
    fi

    if [ "$has_errors" = true ]; then
        log_error "代码质量检查发现问题"
        return 1
    else
        log_success "代码质量检查完成，未发现问题"
    fi
}

# 检查 Ruby 代码质量
check_ruby_quality() {
    log_info "检查 Ruby 代码质量..."

    if command -v rubocop >/dev/null 2>&1; then
        if rubocop "$PROJECT_ROOT/Casks" 2>/dev/null; then
            log_success "Ruby 代码质量检查通过"
            return 0
        else
            log_warning "Ruby 代码质量检查发现问题"
            return 1
        fi
    else
        log_warning "rubocop 未安装，跳过 Ruby 代码检查"
        return 0
    fi
}

# 检查 Shell 脚本质量
check_shell_quality() {
    log_info "检查 Shell 脚本质量..."

    if command -v shellcheck >/dev/null 2>&1; then
        local shell_files
        shell_files=$(find "$SCRIPT_DIR" -name "*.sh" -type f)

        if [[ -n "$shell_files" ]]; then
            if echo "$shell_files" | xargs shellcheck; then
                log_success "Shell 脚本质量检查通过"
                return 0
            else
                log_warning "Shell 脚本质量检查发现问题"
                return 1
            fi
        else
            log_info "未找到 Shell 脚本文件"
            return 0
        fi
    else
        log_warning "shellcheck 未安装，跳过 Shell 脚本检查"
        return 0
    fi
}

# 检查 YAML 文件质量
check_yaml_quality() {
    log_info "检查 YAML 文件质量..."

    if command -v yamllint >/dev/null 2>&1; then
        if yamllint "$PROJECT_ROOT" 2>/dev/null; then
            log_success "YAML 文件质量检查通过"
            return 0
        else
            log_warning "YAML 文件质量检查发现问题"
            return 1
        fi
    else
        log_warning "yamllint 未安装，跳过 YAML 文件检查"
        return 0
    fi
}

# 检查 Markdown 文件质量
check_markdown_quality() {
    log_info "检查 Markdown 文件质量..."

    if command -v markdownlint >/dev/null 2>&1; then
        if markdownlint "$PROJECT_ROOT" 2>/dev/null; then
            log_success "Markdown 文件质量检查通过"
            return 0
        else
            log_warning "Markdown 文件质量检查发现问题"
            return 1
        fi
    else
        log_warning "markdownlint 未安装，跳过 Markdown 文件检查"
        return 0
    fi
}

# 发布相关操作
release_operations() {
    log_step "发布操作..."

    case "${1:-}" in
        --prepare)
            log_info "准备发布..."
            validate_casks --all
            run_tests --all
            log_success "发布准备完成"
            ;;
        --changelog)
            log_info "生成变更日志..."
            # 这里可以添加变更日志生成逻辑
            log_warning "变更日志生成功能待实现"
            ;;
        --tag)
            log_info "创建发布标签..."
            # 这里可以添加标签创建逻辑
            log_warning "标签创建功能待实现"
            ;;
        *)
            log_error "请指定发布操作: --prepare, --changelog, --tag"
            return 1
            ;;
    esac
}

# 项目统计信息
show_stats() {
    log_step "项目统计信息..."

    case "${1:-}" in
        --casks)
            log_info "Cask 文件统计:"
            local cask_count
            cask_count=$(find "$PROJECT_ROOT/Casks" -name "*.rb" | wc -l | tr -d ' ')
            echo "  总数: $cask_count"
            echo "  详细列表:"
            find "$PROJECT_ROOT/Casks" -name "*.rb" -exec basename {} .rb \; | sort | sed 's/^/    - /'
            ;;
        --commits)
            log_info "提交统计:"
            if git rev-parse --git-dir > /dev/null 2>&1; then
                echo "  总提交数: $(git rev-list --all --count)"
                echo "  最近提交: $(git log -1 --format='%h %s (%cr)')"
            else
                log_warning "不在 Git 仓库中"
            fi
            ;;
        --contributors)
            log_info "贡献者统计:"
            if git rev-parse --git-dir > /dev/null 2>&1; then
                git shortlog -sn | head -10
            else
                log_warning "不在 Git 仓库中"
            fi
            ;;
        *)
            show_stats --casks
            show_stats --commits
            show_stats --contributors
            ;;
    esac
}

# 主函数
main() {
    # 切换到项目根目录
    cd "$PROJECT_ROOT"

    # 检查参数
    if [[ $# -eq 0 ]]; then
        show_help
        return 0
    fi

    local command="$1"
    shift

    case "$command" in
        validate)
            validate_casks "$@"
            ;;
        fix)
            fix_casks "$@"
            ;;
        test)
            run_tests "$@"
            ;;
        setup)
            setup_environment "$@"
            ;;
        clean)
            clean_project "$@"
            ;;
        lint)
            lint_code "$@"
            ;;
        quality)
            quality_check "$@"
            ;;
        release)
            release_operations "$@"
            ;;
        stats)
            show_stats "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            echo
            show_help
            return 1
            ;;
    esac
}

# 运行主函数
main "$@"
