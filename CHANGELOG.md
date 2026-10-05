# HarborAPI 更新日志

本文件记录每次更新的版本变化和改动内容。

## [未发布]

### 新增
- 🎉 初始化 HarborAPI 部署仓库
- ✨ 统一的 Docker Compose 配置（new-api + sub2api + PostgreSQL + Redis + Caddy）
- 🔐 自动密钥生成脚本 (`./scripts/generate-secrets.sh`)
- 🚀 一键部署脚本 (`./scripts/install.sh`)
- 🔄 便捷更新脚本 (`./scripts/update.sh`)
- 🎨 HarborAPI 主题（暖色调大地色系）
- 📦 GitHub Actions 自动构建工作流
- 📚 详细的架构文档 (ARCHITECTURE.md)

### 配置
- **new-api**: 基于 v1.0.0-rc.41
- **sub2api**: 基于 v0.2.13
- **PostgreSQL**: 18-alpine
- **Redis**: 8-alpine
- **Caddy**: 2-alpine

### 定制
- 禁用 sub2api 内置更新按钮（防止覆盖定制版）
- 导入 HarborAPI 自定义主题
- 修改页面标题为 "HarborAPI"
- 预留 Logo 替换位置

---

## 版本说明

HarborAPI 的版本号遵循以下规则：
- 仓库本身采用语义化版本 (SemVer)
- 各组件版本独立追踪在 `<component>/version.txt` 中
- 镜像标签同时包含组件版本和 `:latest` 标签

示例:
- `harbor-new-api:v1.0.0-rc.41` - 基于 new-api v1.0.0-rc.41
- `harbor-sub2api:0.2.13` - 基于 sub2api 0.2.13
