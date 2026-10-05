# HarborAPI

<div align="center">

**AI API 网关 —— 统一部署 new-api 和 sub2api**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-required-blue.svg)](https://www.docker.com/)
[![new-api](https://img.shields.io/badge/new--api-v1.0.0--rc.41-green.svg)](https://github.com/QuantumNous/new-api)
[![sub2api](https://img.shields.io/badge/sub2api-0.2.13-green.svg)](https://github.com/Wei-Shaw/sub2api)

</div>

---

## ✨ 特性

- 🚀 **一键部署** - 单条命令完成所有服务部署
- 🔄 **独立更新** - 分别更新 new-api 或 sub2api，自动健康检查和回滚
- 🎨 **统一品牌** - HarborAPI 主题，暖色调大地色系设计
- 🔐 **安全加固** - 自动生成强密钥，HTTPS 自动证书
- 📦 **多架构支持** - amd64 和 arm64 镜像自动构建
- 💾 **数据持久化** - PostgreSQL 18 + Redis 8，定期备份
- 🌐 **国产模型支持** - 完整支持通义千问、文心一言等国内 AI 模型

## 🏗️ 架构

```
         HTTPS (Caddy)
              │
    ┌─────────┴─────────┐
    │                   │
new-api           sub2api
(API 网关)        (订阅管理)
    │                   │
    └─────────┬─────────┘
              │
    PostgreSQL + Redis
```

- **new-api**: OpenAI 兼容 API 网关，支持多种上游和国产模型
- **sub2api**: 订阅账号管理，支持共享和计费
- **PostgreSQL**: 关系型数据库
- **Redis**: 缓存和会话存储
- **Caddy**: 自动 HTTPS 和反向代理

详见 [架构文档](ARCHITECTURE.md)

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Docker Compose v2.0+
- 1 核 1GB 内存最低配置

### 三步部署

```bash
# 1. 克隆仓库
git clone https://github.com/xu158185/harbor-api.git
cd harbor-api

# 2. 生成配置和密钥
./scripts/generate-secrets.sh

# 3. 编辑域名（生产环境）
nano .env  # 修改 DOMAIN=your-domain.com

# 4. 启动服务
./scripts/install.sh
```

5 分钟后访问：
- **API 网关**: `https://your-domain.com`
- **管理后台**: `https://your-domain.com/admin`

> 📖 **初次使用？** 参考 [5 分钟快速开始](QUICKSTART.md) | 详细步骤见 [部署指南](DEPLOYMENT.md)

## 🔄 更新服务

```bash
# 更新 new-api
./scripts/update.sh new-api

# 更新 sub2api
./scripts/update.sh sub2api

# 更新所有
./scripts/update.sh all
```

更新脚本自动处理：
- ✅ 拉取最新镜像
- ✅ 健康检查
- ✅ 失败时保留旧版本
- ✅ 显示详细日志

## 📖 文档

- [部署指南](DEPLOYMENT.md) - 完整的安装、配置、维护指南
- [架构说明](ARCHITECTURE.md) - 技术架构、更新机制、故障排查
- [更新日志](CHANGELOG.md) - 版本历史和变更记录
- [贡献指南](CONTRIBUTING.md) - 如何参与项目开发

## 🎨 自定义品牌

### HarborAPI 主题

默认主题使用温暖大地色系：

- **调色板**: 奶油色背景 + 陶土色主调
- **字体**: Fraunces 衬线 + Inter 无衬线
- **风格**: 圆角按钮、毛玻璃导航、悬停提升

主题文件: [`new-api/overlay/web/src/styles/harbor-theme.css`](new-api/overlay/web/src/styles/harbor-theme.css)

### 替换 Logo

1. 准备文件:
   - new-api: `new-api/overlay/web/public/logo-harbor.png`
   - sub2api: `sub2api/overlay/frontend/public/logo-harbor.svg`

2. 重新构建镜像（通过 GitHub Actions 或本地 Docker）

## 💡 常见问题

### 如何修改管理员密码？

首次部署前在 `.env` 中设置 `ADMIN_PASSWORD`，或首次访问时在 Web UI 中设置。

### 如何添加国产模型？

在 new-api 管理界面中：
1. 添加渠道（通义千问、文心一言等）
2. 配置 API Key
3. 创建令牌分配给用户

sub2api 支持的国产模型通过其订阅机制自动同步。

### 内存占用多少？

实测 6 个容器总计约 **200MB**：
- PostgreSQL: ~30MB
- Redis: ~10MB
- sub2api: ~50MB
- new-api: ~80MB
- Caddy: ~20MB

1GB 内存的 VPS 完全够用。

### 如何备份数据？

```bash
# 备份数据库
docker compose exec postgres pg_dump -U harborapi harborapi > backup.sql

# 备份配置
tar -czf backup.tar.gz .env docker-compose.yml
```

更多问题见 [部署指南 - 故障排查](DEPLOYMENT.md#故障排查)

## 📊 资源占用

| 资源 | 使用量 | 说明 |
|------|--------|------|
| **内存** | ~200MB | 所有容器总计 |
| **存储** | ~500MB | 初始安装，随使用增长 |
| **CPU** | 低 | 空闲时几乎无占用 |
| **带宽** | 按需 | 取决于 API 调用量 |

推荐配置：1 核 1GB 内存起步，2 核 2GB 更佳。

## 🔒 安全建议

- ✅ 使用 `generate-secrets.sh` 生成强密钥
- ✅ 生产环境设置 `BIND_HOST=127.0.0.1`
- ✅ 定期运行 `update.sh` 检查更新
- ✅ 配置防火墙只开放 80/443 端口
- ✅ 定期备份数据库

## 📜 许可证

本仓库（部署脚本和配置）采用 [MIT License](LICENSE)。

**上游项目**:
- [new-api](https://github.com/QuantumNous/new-api) - AGPL-3.0（必须保留署名）
- [sub2api](https://github.com/Wei-Shaw/sub2api) - LGPL-3.0

详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

请阅读 [贡献指南](CONTRIBUTING.md) 了解如何参与。

## 🙏 致谢

HarborAPI 基于以下优秀开源项目：

- [new-api](https://github.com/QuantumNous/new-api) by @QuantumNous
- [sub2api](https://github.com/Wei-Shaw/sub2api) by @Wei-Shaw
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [Caddy](https://caddyserver.com/)

感谢所有贡献者的辛勤付出！

## ⭐ Star History

如果这个项目对你有帮助，请给个 Star ⭐️

---

<div align="center">

Made with ❤️ by [xu158185](https://github.com/xu158185)

</div>
