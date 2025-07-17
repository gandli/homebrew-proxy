# 贡献指南

感谢您对Homebrew Proxy Tap项目的关注！我们欢迎并感谢任何形式的贡献。本指南将帮助您了解如何为项目做出贡献。

## 贡献流程

### 1. 准备工作

在开始贡献之前，请确保：

1. 您已经有一个GitHub账户
2. 您已经安装了[Homebrew](https://brew.sh/)
3. 您已经设置了开发环境（参见[开发环境设置](./development-setup.md)）

### 2. 寻找任务

您可以通过以下方式找到需要帮助的任务：

- 查看[GitHub Issues](https://github.com/gandli/homebrew-proxy/issues)
- 检查现有Cask是否需要更新
- 考虑添加新的代理工具
- 改进文档或自动化脚本

### 3. 创建分支

1. Fork项目仓库
2. 克隆您的fork到本地：

   ```bash
   git clone https://github.com/YOUR_USERNAME/homebrew-proxy.git
   cd homebrew-proxy
   ```

3. 添加上游仓库：

   ```bash
   git remote add upstream https://github.com/gandli/homebrew-proxy.git
   ```

4. 创建新分支：

   ```bash
   git checkout -b feature/your-feature-name
   ```

### 4. 进行更改

根据您的贡献类型，您可能需要：

- 添加或更新Cask文件
- 改进文档
- 修复错误
- 添加新功能

请确保遵循我们的[代码质量标准](../technical-standards/code-quality-standards.md)和[格式标准](../technical-standards/format-standards.md)。

### 5. 测试您的更改

在提交之前，请确保：

- 运行`make validate`验证所有Cask文件
- 如果添加或修改了Cask，请测试安装：`brew install --cask ./Casks/your-cask.rb`
- 如果更改了脚本，请测试其功能

### 6. 提交更改

1. 添加更改的文件：

   ```bash
   git add .
   ```

2. 提交更改，使用清晰的提交消息：

   ```bash
   git commit -m "Add: new cask for example-tool"
   ```

   提交消息应遵循以下格式：
   - `Add:` - 添加新功能或文件
   - `Update:` - 更新现有功能或文件
   - `Fix:` - 修复错误
   - `Docs:` - 文档更改
   - `Test:` - 添加或修改测试
   - `Refactor:` - 代码重构
   - `Chore:` - 维护任务

3. 推送到您的fork：

   ```bash
   git push origin feature/your-feature-name
   ```

### 7. 创建Pull Request

1. 访问您的GitHub仓库
2. 点击"Compare & pull request"
3. 填写PR模板，提供清晰的描述
4. 提交PR

### 8. 代码审查

- 维护者将审查您的PR
- 可能会要求进行更改
- 请及时响应反馈

### 9. 合并

一旦您的PR被批准，维护者将合并它。恭喜，您已成功贡献！

## 贡献类型

### 添加新的Cask

请参阅[Cask创建指南](./cask-creation.md)了解详细步骤。

### 更新现有Cask

1. 检查最新版本
2. 更新版本号和SHA256
3. 测试安装
4. 提交PR

### 改进文档

1. 找到需要改进的文档
2. 进行必要的更改
3. 确保格式正确
4. 提交PR

### 报告问题

如果您发现问题但不确定如何修复，请[创建Issue](https://github.com/gandli/homebrew-proxy/issues/new)，提供：

- 问题的详细描述
- 重现步骤
- 预期行为
- 实际行为
- 系统信息（macOS版本、Homebrew版本等）

## 行为准则

- 尊重所有贡献者
- 提供建设性的反馈
- 保持专业态度
- 关注问题，而非人

## 获取帮助

如果您在贡献过程中需要帮助，可以：

- 在相关Issue中提问
- 在PR中提问
- 联系项目维护者

再次感谢您的贡献！
