# 贡献指南

感谢你对 HarborAPI 项目的关注！

## 报告问题

发现 Bug 或有功能建议？请在 [Issues](https://github.com/xu158185/harbor-api/issues) 中提交。

提交前请：
1. 搜索现有 Issue，避免重复
2. 使用清晰的标题
3. 提供复现步骤（对于 Bug）
4. 说明你的环境（OS、Docker 版本等）

## 提交代码

### 开发流程

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 进行修改并测试
4. 提交：`git commit -m "feat: your feature"`
5. 推送：`git push origin feature/your-feature`
6. 提交 Pull Request

### 提交信息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

- `feat:` 新功能
- `fix:` 修复 Bug
- `docs:` 文档修改
- `style:` 代码格式（不影响功能）
- `refactor:` 重构
- `test:` 测试相关
- `chore:` 构建/工具链相关

示例：
```
feat: add health check endpoint
fix: resolve database connection timeout
docs: update deployment guide
```

### 代码规范

- Shell 脚本：遵循 [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- YAML/Docker Compose：使用 2 空格缩进
- Markdown：每行不超过 120 字符（代码块除外）

### 测试

在提交 PR 前，请确保：

1. **本地测试**：
   ```bash
   ./scripts/install.sh
   docker compose ps  # 确保所有容器健康
   ```

2. **更新脚本测试**：
   ```bash
   ./scripts/update.sh new-api
   ./scripts/update.sh sub2api
   ```

3. **清理测试**：
   ```bash
   docker compose down
   docker compose up -d
   ```

## 自定义主题

想要分享你的自定义主题？

1. 在 `new-api/overlay/web/src/styles/` 创建新的 CSS 文件
2. 在 PR 中包含截图
3. 说明你的设计理念

## 许可证

提交代码即表示你同意：
- 你的贡献采用 MIT 许可证（本仓库部分）
- 涉及上游项目（new-api, sub2api）的修改需遵守其原许可证

## 行为准则

- 尊重他人
- 保持建设性讨论
- 接受不同意见
- 专注于问题本身

## 联系方式

- GitHub Issues: https://github.com/xu158185/harbor-api/issues
- 上游项目问题请直接联系原作者
