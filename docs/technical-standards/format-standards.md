# 格式规范统一标准

本文档描述了项目中各种代码质量工具的统一配置标准，解决了之前存在的格式规范冲突问题。

## 统一标准概述

为确保项目中所有文件的一致性，我们制定了以下统一标准：

- **行长度**: 所有文件类型统一为120字符
- **缩进**: 所有文件类型统一使用2个空格
- **尾随空格**: 所有文件类型统一移除尾随空格（Markdown换行除外）
- **文件结尾**: 所有文件统一以换行符结尾

## 修复的冲突问题

### 1. 行长度限制统一

**问题**: 不同工具的行长度限制不一致

- yamllint: 200 字符
- markdownlint: 120 字符  
- rubocop: 120 字符

**解决方案**: 统一设置为 120 字符

- ✅ yamllint: `max: 120`
- ✅ markdownlint: `line_length: 120`
- ✅ rubocop: `Max: 120`

### 2. 缩进规则统一

**标准**: 所有配置文件使用 2 个空格缩进

- ✅ YAML 文件: 2 个空格
- ✅ Ruby 文件: 2 个空格
- ✅ Markdown 文件: 2 个空格（列表缩进）

### 3. Pre-commit 工具配置优化

**改进**:

- 🔧 RuboCop: 使用 `--auto-correct-all` 替代 `--auto-correct`
- 🔧 Markdownlint: 添加 `--fix` 参数自动修复
- 🔧 Commitizen: 添加 `always_run` 和 `pass_filenames` 配置

### 4. GitHub Actions 版本更新

**升级**:

- 🆙 Python setup: v4 → v5，版本指定为 3.11
- 🆙 Node.js: 18 → 20
- 🆙 Cache action: v3 → v4，添加恢复键
- 🆙 Upload artifact: v3 → v4，添加保留期限

## 详细配置标准

### 行长度

```yaml
最大行长度: 120 字符
例外情况:
  - URL 链接
  - SHA256 哈希值
  - 长注释行
  - Cask 文件中的特定字段
```

### 缩进

```yaml
缩进标准: 2 个空格
适用范围:
  - YAML 文件
  - Ruby 文件
  - Markdown 列表
  - JSON 文件
```

### 尾随空格

```yaml
规则: 移除所有尾随空格
例外: Markdown 中的换行标记
```

### 文件结尾

```yaml
规则: 所有文件以换行符结尾
检查工具: pre-commit end-of-file-fixer
```

## 工具配置文件

### 主要配置文件

- `.pre-commit-config.yaml` - Pre-commit 钩子配置
- `.yamllint.yml` - YAML 文件检查配置
- `.markdownlint.json` - Markdown 文件检查配置
- `.rubocop.yml` - Ruby 代码检查配置
- `.shellcheckrc` - Shell 脚本检查配置

### 配置继承关系

```text
.rubocop.yml
├── inherit_from: .rubocop_todo.yml
└── 项目特定规则

.pre-commit-config.yaml
├── 调用所有工具
└── 统一参数配置
```

## 配置文件示例

### .rubocop.yml

```yaml
inherit_from: .rubocop_todo.yml

AllCops:
  TargetRubyVersion: 2.6
  NewCops: enable

Layout/LineLength:
  Max: 120
  Exclude:
    - 'Casks/**/*'

Style/StringLiterals:
  EnforcedStyle: double_quotes

Style/FrozenStringLiteralComment:
  Enabled: false
```

### .yamllint.yml

```yaml
extends: default

rules:
  line-length:
    max: 120
    level: warning
  indentation:
    spaces: 2
    indent-sequences: consistent
  document-start:
    present: false
  truthy:
    allowed-values: ['true', 'false', 'yes', 'no']
```

### .markdownlint.json

```json
{
  "default": true,
  "line_length": {
    "line_length": 120,
    "tables": false,
    "code_blocks": false
  },
  "no-trailing-spaces": {
    "br_spaces": 2
  },
  "no-multiple-blanks": {
    "maximum": 1
  }
}
```

## 使用指南

### 本地开发

```bash
# 安装 pre-commit
pip install pre-commit

# 安装钩子
pre-commit install

# 手动运行所有检查
pre-commit run --all-files
```

### CI/CD 流程

```bash
# GitHub Actions 自动运行
# 包含所有质量检查工具
# 生成质量报告
```

### 修复常见问题

```bash
# 自动修复 Ruby 代码
rubocop --auto-correct-all

# 自动修复 Markdown
markdownlint --fix .

# 检查 YAML 语法
yamllint .

# 检查 Shell 脚本
shellcheck .github/scripts/*.sh
```

## 最佳实践

### 1. 提交前检查

- 确保 pre-commit 钩子已安装
- 运行 `pre-commit run --all-files` 检查所有文件
- 修复所有报告的问题

1. **配置文件维护**

   - 定期更新工具版本
   - 保持配置文件同步
   - 记录重要的配置变更

2. **团队协作**

   - 所有团队成员使用相同的配置
   - 在 PR 中检查格式规范
   - 及时修复 CI 中的格式问题

## 故障排除

### 常见错误

1. **行长度超限**

   ```text
   解决: 重构长行或添加例外规则
   ```

2. **缩进不一致**

   ```text
   解决: 使用编辑器的格式化功能
   ```

3. **尾随空格**

   ```text
   解决: 配置编辑器自动移除尾随空格
   ```

4. **Pre-commit 失败**

   ```bash
   # 清理缓存重新安装
   pre-commit clean
   pre-commit install
   ```

## 获取帮助

- 查看具体工具的文档
- 检查 GitHub Actions 日志
- 运行本地测试确认问题
