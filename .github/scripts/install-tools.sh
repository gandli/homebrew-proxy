#!/bin/bash

# 安装开发工具脚本
# 用于安装项目所需的所有代码质量检查工具

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查包管理器
check_package_managers() {
    log_info "检查包管理器..."

    # 检查 Homebrew
    if command_exists brew; then
        log_success "Homebrew 已安装"
        BREW_AVAILABLE=true
    else
        log_warning "Homebrew 未安装"
        BREW_AVAILABLE=false
    fi

    # 检查 pip
    if command_exists pip || command_exists pip3; then
        log_success "pip 已安装"
        PIP_AVAILABLE=true
    else
        log_warning "pip 未安装"
        PIP_AVAILABLE=false
    fi

    # 检查 npm
    if command_exists npm; then
        log_success "npm 已安装"
        NPM_AVAILABLE=true
    else
        log_warning "npm 未安装"
        NPM_AVAILABLE=false
    fi

    # 检查 gem
    if command_exists gem; then
        log_success "gem 已安装"
        GEM_AVAILABLE=true
    else
        log_warning "gem 未安装"
        GEM_AVAILABLE=false
    fi
}

# 安装 ShellCheck
install_shellcheck() {
    if command_exists shellcheck; then
        log_success "ShellCheck 已安装"
        return 0
    fi

    log_info "安装 ShellCheck..."

    if [ "$BREW_AVAILABLE" = true ]; then
        brew install shellcheck
        log_success "ShellCheck 安装完成"
    else
        log_error "无法安装 ShellCheck: Homebrew 未安装"
        return 1
    fi
}

# 安装 yamllint
install_yamllint() {
    if command_exists yamllint; then
        log_success "yamllint 已安装"
        return 0
    fi

    log_info "安装 yamllint..."

    if [ "$PIP_AVAILABLE" = true ]; then
        if command_exists pip3; then
            pip3 install yamllint
        else
            pip install yamllint
        fi
        log_success "yamllint 安装完成"
    else
        log_error "无法安装 yamllint: pip 未安装"
        return 1
    fi
}

# 安装 markdownlint
install_markdownlint() {
    if command_exists markdownlint; then
        log_success "markdownlint 已安装"
        return 0
    fi

    log_info "安装 markdownlint..."

    if [ "$NPM_AVAILABLE" = true ]; then
        npm install -g markdownlint-cli
        log_success "markdownlint 安装完成"
    else
        log_error "无法安装 markdownlint: npm 未安装"
        return 1
    fi
}

# 安装 RuboCop
install_rubocop() {
    if command_exists rubocop; then
        log_success "RuboCop 已安装"
        return 0
    fi

    log_info "安装 RuboCop..."

    if [ "$GEM_AVAILABLE" = true ]; then
        gem install rubocop
        log_success "RuboCop 安装完成"
    else
        log_error "无法安装 RuboCop: gem 未安装"
        return 1
    fi
}

# 安装 pre-commit
install_precommit() {
    if command_exists pre-commit; then
        log_success "pre-commit 已安装"
        return 0
    fi

    log_info "安装 pre-commit..."

    if [ "$PIP_AVAILABLE" = true ]; then
        if command_exists pip3; then
            pip3 install pre-commit
        else
            pip install pre-commit
        fi
        log_success "pre-commit 安装完成"
    elif [ "$BREW_AVAILABLE" = true ]; then
        brew install pre-commit
        log_success "pre-commit 安装完成"
    else
        log_error "无法安装 pre-commit: pip 和 Homebrew 都未安装"
        return 1
    fi
}

# 安装 commitizen
install_commitizen() {
    if command_exists cz; then
        log_success "commitizen 已安装"
        return 0
    fi

    log_info "安装 commitizen..."

    if [ "$PIP_AVAILABLE" = true ]; then
        if command_exists pip3; then
            pip3 install commitizen
        else
            pip install commitizen
        fi
        log_success "commitizen 安装完成"
    else
        log_error "无法安装 commitizen: pip 未安装"
        return 1
    fi
}

# 设置 pre-commit 钩子
setup_precommit_hooks() {
    if [ ! -f ".pre-commit-config.yaml" ]; then
        log_warning "未找到 .pre-commit-config.yaml 文件"
        return 1
    fi

    log_info "设置 pre-commit 钩子..."

    if command_exists pre-commit; then
        pre-commit install
        pre-commit install --hook-type commit-msg
        log_success "pre-commit 钩子设置完成"
    else
        log_error "pre-commit 未安装，无法设置钩子"
        return 1
    fi
}

# 验证安装
verify_installation() {
    log_info "验证工具安装..."

    local all_installed=true

    # 检查每个工具
    tools=("shellcheck" "yamllint" "markdownlint" "rubocop" "pre-commit")

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            log_success "✓ $tool 已安装"
        else
            log_error "✗ $tool 未安装"
            all_installed=false
        fi
    done

    if [ "$all_installed" = true ]; then
        log_success "所有工具安装完成！"
        return 0
    else
        log_error "部分工具安装失败"
        return 1
    fi
}

# 显示帮助信息
show_help() {
    echo "开发工具安装脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --all          安装所有工具"
    echo "  --shellcheck   安装 ShellCheck"
    echo "  --yamllint     安装 yamllint"
    echo "  --markdownlint 安装 markdownlint"
    echo "  --rubocop      安装 RuboCop"
    echo "  --precommit    安装 pre-commit"
    echo "  --commitizen   安装 commitizen"
    echo "  --setup-hooks  设置 pre-commit 钩子"
    echo "  --verify       验证安装"
    echo "  --help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --all                # 安装所有工具"
    echo "  $0 --shellcheck --rubocop  # 只安装 ShellCheck 和 RuboCop"
    echo "  $0 --verify             # 验证所有工具是否已安装"
}

# 主函数
main() {
    # 初始化变量
    BREW_AVAILABLE=false
    PIP_AVAILABLE=false
    NPM_AVAILABLE=false
    GEM_AVAILABLE=false

    # 检查包管理器
    check_package_managers

    # 处理命令行参数
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                install_shellcheck
                install_yamllint
                install_markdownlint
                install_rubocop
                install_precommit
                install_commitizen
                setup_precommit_hooks
                verify_installation
                shift
                ;;
            --shellcheck)
                install_shellcheck
                shift
                ;;
            --yamllint)
                install_yamllint
                shift
                ;;
            --markdownlint)
                install_markdownlint
                shift
                ;;
            --rubocop)
                install_rubocop
                shift
                ;;
            --precommit)
                install_precommit
                shift
                ;;
            --commitizen)
                install_commitizen
                shift
                ;;
            --setup-hooks)
                setup_precommit_hooks
                shift
                ;;
            --verify)
                verify_installation
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 运行主函数
main "$@"
