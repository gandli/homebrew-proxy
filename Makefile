# Makefile for homebrew-proxy project
# 提供便捷的项目管理命令

# 默认目标
.DEFAULT_GOAL := help

# 变量定义
SCRIPT_DIR := .github/scripts
DEV_TOOLS := $(SCRIPT_DIR)/dev-tools.sh
CASKS_DIR := Casks
DOCS_DIR := .github

# 颜色定义
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m

# 检查必要工具
check-tools:
	@command -v brew >/dev/null 2>&1 || { echo "$(RED)错误: 请先安装 Homebrew$(NC)"; exit 1; }
	@test -f $(DEV_TOOLS) || { echo "$(RED)错误: 开发工具脚本不存在$(NC)"; exit 1; }
	@chmod +x $(DEV_TOOLS)

.PHONY: check-tools-verbose
check-tools-verbose: ## 详细检查必要工具是否安装
	@echo "$(BLUE)🔍 检查必要工具...$(NC)"
	@command -v brew >/dev/null 2>&1 || { echo "$(RED)❌ Homebrew 未安装$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Homebrew 已安装$(NC)"
	@if command -v git >/dev/null 2>&1; then echo "$(GREEN)✅ Git 已安装$(NC)"; else echo "$(YELLOW)⚠️  Git 未安装$(NC)"; fi
	@if command -v ruby >/dev/null 2>&1; then echo "$(GREEN)✅ Ruby 已安装$(NC)"; else echo "$(YELLOW)⚠️  Ruby 未安装$(NC)"; fi
	@if command -v rubocop >/dev/null 2>&1; then echo "$(GREEN)✅ RuboCop 已安装$(NC)"; else echo "$(YELLOW)⚠️  RuboCop 未安装 (运行 make rubocop-install)$(NC)"; fi
	@if command -v shellcheck >/dev/null 2>&1; then echo "$(GREEN)✅ ShellCheck 已安装$(NC)"; else echo "$(YELLOW)⚠️  ShellCheck 未安装 (brew install shellcheck)$(NC)"; fi
	@if command -v yamllint >/dev/null 2>&1; then echo "$(GREEN)✅ yamllint 已安装$(NC)"; else echo "$(YELLOW)⚠️  yamllint 未安装 (pip install yamllint)$(NC)"; fi
	@if command -v markdownlint >/dev/null 2>&1; then echo "$(GREEN)✅ markdownlint 已安装$(NC)"; else echo "$(YELLOW)⚠️  markdownlint 未安装 (npm install -g markdownlint-cli)$(NC)"; fi
	@if command -v pre-commit >/dev/null 2>&1; then echo "$(GREEN)✅ pre-commit 已安装$(NC)"; else echo "$(YELLOW)⚠️  pre-commit 未安装 (pip install pre-commit)$(NC)"; fi

# 帮助信息
.PHONY: help
help: ## 显示帮助信息
	@echo "$(CYAN)🍺 Homebrew Proxy 项目管理工具$(NC)"
	@echo ""
	@echo "$(YELLOW)可用命令:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)示例:$(NC)"
	@echo "  make setup          # 设置开发环境"
	@echo "  make validate       # 验证所有 Cask 文件"
	@echo "  make fix            # 修复格式问题"
	@echo "  make test           # 运行测试"
	@echo "  make clean          # 清理项目"

# 开发环境设置
.PHONY: setup
setup: check-tools ## 设置开发环境
	@echo "$(BLUE)🔧 设置开发环境...$(NC)"
	@$(DEV_TOOLS) setup
	@chmod +x $(DEV_TOOLS)
	@chmod +x $(SCRIPT_DIR)/install-tools.sh
	@echo "$(GREEN)✅ 开发环境设置完成$(NC)"

.PHONY: setup-deps
setup-deps: check-tools ## 检查和安装依赖
	@$(DEV_TOOLS) setup --deps

.PHONY: setup-hooks
setup-hooks: check-tools ## 设置 Git hooks
	@$(DEV_TOOLS) setup --hooks

.PHONY: setup-config
setup-config: check-tools ## 配置开发环境
	@$(DEV_TOOLS) setup --config

# 验证和修复
.PHONY: validate
validate: check-tools ## 验证所有 Cask 文件
	@echo "$(BLUE)🔍 验证 Cask 文件...$(NC)"
	@$(DEV_TOOLS) validate --all

.PHONY: validate-file
validate-file: check-tools ## 验证指定的 Cask 文件 (用法: make validate-file FILE=Casks/app.rb)
	@test -n "$(FILE)" || { echo "$(RED)错误: 请指定文件 FILE=Casks/app.rb$(NC)"; exit 1; }
	@$(DEV_TOOLS) validate --file $(FILE)

.PHONY: fix
fix: check-tools ## 修复所有 Cask 文件的格式问题
	@echo "$(BLUE)🔧 修复 Cask 文件...$(NC)"
	@$(DEV_TOOLS) fix --all

.PHONY: fix-file
fix-file: check-tools ## 修复指定的 Cask 文件 (用法: make fix-file FILE=Casks/app.rb)
	@test -n "$(FILE)" || { echo "$(RED)错误: 请指定文件 FILE=Casks/app.rb$(NC)"; exit 1; }
	@$(DEV_TOOLS) fix --file $(FILE)

.PHONY: fix-dry-run
fix-dry-run: check-tools ## 干运行修复（仅显示需要修复的内容）
	@$(DEV_TOOLS) fix --dry-run

# 测试
.PHONY: test
test: check-tools ## 运行所有测试
	@echo "$(BLUE)🧪 运行测试...$(NC)"
	@$(DEV_TOOLS) test --all

.PHONY: test-unit
test-unit: check-tools ## 运行单元测试
	@$(DEV_TOOLS) test --unit

.PHONY: test-integration
test-integration: check-tools ## 运行集成测试
	@$(DEV_TOOLS) test --integration

# 代码检查
.PHONY: lint
lint: check-tools ## 检查代码格式
	@echo "$(BLUE)🔍 检查代码格式...$(NC)"
	@$(DEV_TOOLS) lint --check

.PHONY: lint-fix
lint-fix: check-tools ## 自动修复代码格式问题
	@echo "$(BLUE)🔧 修复代码格式...$(NC)"
	@$(DEV_TOOLS) lint --fix

.PHONY: quality
quality: check-tools ## 运行完整代码质量检查
	@echo "$(BLUE)🔍 运行完整代码质量检查...$(NC)"
	@$(DEV_TOOLS) quality

.PHONY: quality-ruby
quality-ruby: check-tools ## 检查 Ruby 代码质量
	@echo "$(BLUE)🔍 检查 Ruby 代码质量...$(NC)"
	@$(DEV_TOOLS) quality --ruby

.PHONY: quality-shell
quality-shell: check-tools ## 检查 Shell 脚本质量
	@echo "$(BLUE)🔍 检查 Shell 脚本质量...$(NC)"
	@$(DEV_TOOLS) quality --shell

.PHONY: pre-commit-install
pre-commit-install: ## 安装 pre-commit 钩子
	@echo "$(BLUE)🔧 安装 pre-commit 钩子...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		pre-commit install --hook-type commit-msg; \
		echo "$(GREEN)✅ pre-commit 钩子安装完成$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  pre-commit 未安装，请先安装: pip install pre-commit$(NC)"; \
	fi

.PHONY: pre-commit-run
pre-commit-run: ## 运行 pre-commit 检查
	@echo "$(BLUE)🔍 运行 pre-commit 检查...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
	else \
		echo "$(YELLOW)⚠️  pre-commit 未安装，请先安装: pip install pre-commit$(NC)"; \
	fi

.PHONY: rubocop-install
rubocop-install: ## 安装 RuboCop
	@echo "$(BLUE)🔧 安装 RuboCop...$(NC)"
	@if command -v gem >/dev/null 2>&1; then \
		gem install rubocop; \
		echo "$(GREEN)✅ RuboCop 安装完成$(NC)"; \
	else \
		echo "$(RED)❌ Ruby 未安装，无法安装 RuboCop$(NC)"; \
	fi

.PHONY: rubocop-config
rubocop-config: ## 生成 RuboCop TODO 配置
	@echo "$(BLUE)🔧 生成 RuboCop TODO 配置...$(NC)"
	@if command -v rubocop >/dev/null 2>&1; then \
		rubocop --auto-gen-config; \
		echo "$(GREEN)✅ RuboCop TODO 配置生成完成$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  RuboCop 未安装，请先运行: make rubocop-install$(NC)"; \
	fi

.PHONY: install-tools
install-tools: ## 安装所有开发工具
	@echo "$(BLUE)🔧 安装所有开发工具...$(NC)"
	@$(SCRIPT_DIR)/install-tools.sh --all

.PHONY: install-tools-verify
install-tools-verify: ## 验证开发工具安装
	@echo "$(BLUE)🔍 验证开发工具安装...$(NC)"
	@$(SCRIPT_DIR)/install-tools.sh --verify

.PHONY: install-shellcheck
install-shellcheck: ## 安装 ShellCheck
	@echo "$(BLUE)🔧 安装 ShellCheck...$(NC)"
	@$(SCRIPT_DIR)/install-tools.sh --shellcheck

.PHONY: install-yamllint
install-yamllint: ## 安装 yamllint
	@echo "$(BLUE)🔧 安装 yamllint...$(NC)"
	@$(SCRIPT_DIR)/install-tools.sh --yamllint

.PHONY: install-markdownlint
install-markdownlint: ## 安装 markdownlint
	@echo "$(BLUE)🔧 安装 markdownlint...$(NC)"
	@$(SCRIPT_DIR)/install-tools.sh --markdownlint

# 清理
.PHONY: clean
clean: ## 清理项目文件
	@echo "$(BLUE)🧹 清理项目...$(NC)"
	@$(DEV_TOOLS) clean --all
	@echo "$(GREEN)✅ 清理完成$(NC)"

.PHONY: clean-cache
clean-cache: ## 清理缓存文件
	@$(DEV_TOOLS) clean --cache

.PHONY: clean-temp
clean-temp: ## 清理临时文件
	@$(DEV_TOOLS) clean --temp

# 统计信息
.PHONY: stats
stats: check-tools ## 显示项目统计信息
	@$(DEV_TOOLS) stats

.PHONY: stats-casks
stats-casks: check-tools ## 显示 Cask 文件统计
	@$(DEV_TOOLS) stats --casks

.PHONY: stats-commits
stats-commits: check-tools ## 显示提交统计
	@$(DEV_TOOLS) stats --commits

.PHONY: stats-contributors
stats-contributors: check-tools ## 显示贡献者统计
	@$(DEV_TOOLS) stats --contributors

# 发布相关
.PHONY: release-prepare
release-prepare: check-tools ## 准备发布
	@echo "$(BLUE)📦 准备发布...$(NC)"
	@$(DEV_TOOLS) release --prepare
	@echo "$(GREEN)✅ 发布准备完成$(NC)"

.PHONY: release-changelog
release-changelog: check-tools ## 生成变更日志
	@$(DEV_TOOLS) release --changelog

.PHONY: release-tag
release-tag: check-tools ## 创建发布标签
	@$(DEV_TOOLS) release --tag

# 开发工作流
.PHONY: dev-workflow
dev-workflow: validate fix validate test ## 完整的开发工作流（验证->修复->再验证->测试）
	@echo "$(GREEN)🎉 开发工作流完成！$(NC)"

.PHONY: quick-check
quick-check: validate test ## 快速检查（验证+测试）
	@echo "$(GREEN)✅ 快速检查完成！$(NC)"

.PHONY: pre-commit
pre-commit: lint-fix validate ## 提交前检查
	@echo "$(GREEN)✅ 提交前检查完成！$(NC)"

# 新 Cask 开发
.PHONY: new-cask
new-cask: ## 创建新的 Cask 文件模板 (用法: make new-cask NAME=app-name)
	@test -n "$(NAME)" || { echo "$(RED)错误: 请指定应用名称 NAME=app-name$(NC)"; exit 1; }
	@test ! -f "$(CASKS_DIR)/$(NAME).rb" || { echo "$(RED)错误: Cask 文件已存在: $(CASKS_DIR)/$(NAME).rb$(NC)"; exit 1; }
	@echo "$(BLUE)📝 创建新的 Cask 文件: $(NAME).rb$(NC)"
	@echo 'cask "$(NAME)" do' > "$(CASKS_DIR)/$(NAME).rb"
	@echo '  version "1.0.0"' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  sha256 "TODO: 添加 SHA256 哈希值"' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  url "https://example.com/download/$(NAME)-#{version}.dmg"' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  name "$(NAME)"' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  desc "TODO: 添加应用描述"' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  homepage "https://example.com/"' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  livecheck do' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '    url :url' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '    strategy :github_latest' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  end' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  app "$(NAME).app"' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  zap trash: [' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '    "~/Library/Application Support/$(NAME)",' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '    "~/Library/Preferences/com.example.$(NAME).plist",' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo '  ]' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo 'end' >> "$(CASKS_DIR)/$(NAME).rb"
	@echo "$(GREEN)✅ Cask 文件已创建: $(CASKS_DIR)/$(NAME).rb$(NC)"
	@echo "$(YELLOW)📝 请编辑文件并填写正确的信息$(NC)"

# 文档生成
.PHONY: docs
docs: ## 生成项目文档
	@echo "$(BLUE)📚 生成项目文档...$(NC)"
	@echo "$(YELLOW)文档生成功能待实现$(NC)"

# 安装和卸载
.PHONY: install-cask
install-cask: ## 安装指定的 Cask (用法: make install-cask NAME=app-name)
	@test -n "$(NAME)" || { echo "$(RED)错误: 请指定应用名称 NAME=app-name$(NC)"; exit 1; }
	@test -f "$(CASKS_DIR)/$(NAME).rb" || { echo "$(RED)错误: Cask 文件不存在: $(CASKS_DIR)/$(NAME).rb$(NC)"; exit 1; }
	@echo "$(BLUE)📦 安装 $(NAME)...$(NC)"
	@brew install --cask "$(CASKS_DIR)/$(NAME).rb"

.PHONY: uninstall-cask
uninstall-cask: ## 卸载指定的 Cask (用法: make uninstall-cask NAME=app-name)
	@test -n "$(NAME)" || { echo "$(RED)错误: 请指定应用名称 NAME=app-name$(NC)"; exit 1; }
	@echo "$(BLUE)🗑️  卸载 $(NAME)...$(NC)"
	@brew uninstall --cask "$(NAME)" || true

# 调试和诊断
.PHONY: debug
debug: ## 启用调试模式运行验证
	@DEBUG=1 $(DEV_TOOLS) validate --all

.PHONY: verbose
verbose: ## 启用详细模式运行验证
	@VERBOSE=1 $(DEV_TOOLS) validate --all

.PHONY: doctor
doctor: check-tools ## 诊断开发环境
	@echo "$(BLUE)🩺 诊断开发环境...$(NC)"
	@echo "$(CYAN)Homebrew 版本:$(NC)"
	@brew --version
	@echo ""
	@echo "$(CYAN)Git 版本:$(NC)"
	@git --version
	@echo ""
	@echo "$(CYAN)项目状态:$(NC)"
	@git status --porcelain || echo "不在 Git 仓库中"
	@echo ""
	@echo "$(CYAN)Cask 文件数量:$(NC)"
	@find $(CASKS_DIR) -name "*.rb" | wc -l | tr -d ' '
	@echo ""
	@echo "$(GREEN)✅ 诊断完成$(NC)"

# 备份和恢复
.PHONY: backup
backup: ## 备份 Cask 文件
	@echo "$(BLUE)💾 备份 Cask 文件...$(NC)"
	@mkdir -p backups
	@tar -czf "backups/casks-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz" $(CASKS_DIR)/
	@echo "$(GREEN)✅ 备份完成$(NC)"

.PHONY: list-backups
list-backups: ## 列出所有备份
	@echo "$(BLUE)📋 备份列表:$(NC)"
	@ls -la backups/ 2>/dev/null || echo "没有找到备份文件"

# 特殊目标
.PHONY: all
all: setup validate fix test quality ## 运行完整的构建流程
	@echo "$(GREEN)🎉 所有任务完成！$(NC)"

# 确保某些目标总是执行
.PHONY: check-tools setup validate fix test clean stats help

# 防止意外删除重要文件
.PRECIOUS: $(CASKS_DIR)/%.rb
