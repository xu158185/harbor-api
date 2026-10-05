# HarborAPI

AI API 网关 —— 基于 new-api 和 sub2api 的一键部署方案

## 特性

- 🚀 一键部署：`./scripts/install.sh` 即可启动
- 🔄 便捷更新：单独更新任一组件，自动健康检查和回滚
- 🎨 统一品牌：HarborAPI 主题和 Logo
- 🔐 HTTPS 就绪：内置 Caddy 自动证书

## 快速开始

```bash
git clone https://github.com/xu158185/harbor-api.git
cd harbor-api
./scripts/install.sh
```

访问 https://your-domain.com，首次访问会进入设置向导。

## 架构

- **new-api**: 对外 API 网关，支持国产模型和多种上游
- **sub2api**: 后端服务，专注于订阅账号管理
- **PostgreSQL 18 + Redis 8**: 数据持久化
- **Caddy 2**: HTTPS 和反向代理

详见 [ARCHITECTURE.md](ARCHITECTURE.md)

## 许可证

本仓库（部署脚本和配置）采用 MIT 许可证。

- new-api 采用 AGPL-3.0，详见 https://github.com/QuantumNous/new-api
- sub2api 采用 LGPL-3.0，详见 https://github.com/Wei-Shaw/sub2api

