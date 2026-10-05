# HarborAPI 架构说明

## 整体架构

```
┌─────────────────────────────────────────────────────┐
│                      Caddy                          │
│         (HTTPS + 反向代理 + 自动证书)                │
└────────────────┬────────────────────────────────────┘
                 │
       ┌─────────┴──────────┐
       │                    │
       ▼                    ▼
┌─────────────┐      ┌─────────────┐
│   new-api   │      │   sub2api   │
│   (3000)    │      │   (8080)    │
│  API 网关   │      │  订阅管理    │
└──────┬──────┘      └──────┬──────┘
       │                    │
       └─────────┬──────────┘
                 │
       ┌─────────┴──────────┐
       │                    │
       ▼                    ▼
┌─────────────┐      ┌─────────────┐
│ PostgreSQL  │      │    Redis    │
│    (5432)   │      │    (6379)   │
└─────────────┘      └─────────────┘
```

## 路由规则

- **/** → new-api (API 网关)
  - 对外提供 OpenAI 兼容 API
  - 管理渠道、令牌、用户
  - 支持国产模型和多种上游

- **/admin/** → sub2api (订阅管理后台)
  - 管理订阅账号
  - 账号共享和计费
  - TOTP 双因素认证

## 数据存储

### PostgreSQL
- **Database**: `harborapi`
- **User**: `harborapi`
- **Port**: 5432 (仅内网)
- **数据卷**: `./postgres_data`

两个服务共享同一个数据库实例，但使用不同的表前缀避免冲突。

### Redis
- **Port**: 6379 (仅内网)
- **数据卷**: `./redis_data`
- **用途**:
  - new-api: DB 1 (缓存、速率限制)
  - sub2api: DB 0 (会话、队列)

## 镜像构建

### 自定义镜像

- `xu158185/harbor-new-api:latest`
  - 基础: `calciumion/new-api:latest`
  - 叠加层: `new-api/overlay/`
  - 补丁: `new-api/patches/*.patch`

- `xu158185/harbor-sub2api:latest`
  - 基础: `weishaw/sub2api:latest`
  - 叠加层: `sub2api/overlay/`
  - 补丁: `sub2api/patches/*.patch`

### GitHub Actions

- **触发条件**:
  - 手动触发 (workflow_dispatch)
  - 上游版本变化 (schedule: 每日检查)

- **构建流程**:
  1. 拉取上游镜像
  2. 应用补丁文件
  3. 复制叠加层文件
  4. 重新打包镜像
  5. 推送到 GHCR/DockerHub

## 更新策略

### 1. 自动检测上游更新
- GitHub Actions 每日检查上游 release
- 发现新版本时自动构建新镜像

### 2. 手动更新部署
```bash
# 更新 new-api
./scripts/update.sh new-api

# 更新 sub2api
./scripts/update.sh sub2api

# 更新所有
./scripts/update.sh all
```

### 3. 健康检查与回滚
- 每次更新后自动健康检查
- 如果启动失败，保留旧容器供回滚
- 日志自动输出便于调试

## 安全配置

### 密钥管理
所有密钥存储在 `.env` 文件中：
- `POSTGRES_PASSWORD`: 数据库密码
- `REDIS_PASSWORD`: Redis 密码
- `JWT_SECRET`: sub2api JWT 签名密钥
- `TOTP_ENCRYPTION_KEY`: TOTP 加密密钥（32 字符）
- `SESSION_SECRET`: new-api session 密钥

使用 `./scripts/generate-secrets.sh` 自动生成。

### 网络隔离
- 数据库和 Redis 仅在内部网络 `harbor-net` 可见
- 只有 Caddy 暴露 80/443 端口
- 应用容器使用 `BIND_HOST=0.0.0.0` 允许内网访问

### HTTPS
- Caddy 自动申请 Let's Encrypt 证书
- 强制 HSTS (Strict-Transport-Security)
- 支持 HTTP/3 (QUIC)

## 品牌定制

### HarborAPI 主题
- 文件: `new-api/overlay/web/src/styles/harbor-theme.css`
- 调色板: 暖色调大地色系（奶油色、陶土色）
- 字体: Fraunces 衬线 + Inter 无衬线
- 特色: 圆角按钮、毛玻璃导航、悬停提升效果

### Logo 和标识
- new-api Logo: `new-api/overlay/web/public/logo-harbor.png`
- sub2api Logo: `sub2api/overlay/frontend/public/logo-harbor.svg`
- 可在 Web UI 设置页面动态修改

## 许可证合规

### AGPL-3.0 (new-api)
- 必须保留页脚署名链接
- 修改后的源代码必须公开
- 通过网络提供服务也需要提供源码

### LGPL-3.0 (sub2api)
- 允许动态链接而不传染
- 修改 sub2api 本身的代码需要公开
- 配置和主题文件不受影响

### MIT (本仓库)
- 部署脚本和配置文件采用 MIT
- 可自由使用、修改、分发

## 资源占用

基于实测（6 个容器）：
- **内存**: ~200MB 总计
  - PostgreSQL: ~30MB
  - Redis: ~10MB
  - sub2api: ~50MB
  - new-api: ~80MB
  - Caddy: ~20MB
- **存储**: ~500MB（初始）
  - 镜像: ~350MB
  - 数据库: ~50MB（随使用增长）
  - 日志: ~10MB/周（可配置轮转）
- **带宽**: 取决于 API 调用量
  - 管理界面: <1MB/次访问
  - API 请求: 按实际流量计费

## 故障排除

### 常见问题

1. **容器启动失败**
   ```bash
   docker compose logs <service>
   docker compose ps
   ```

2. **数据库连接错误**
   - 检查 `.env` 中的密码是否正确
   - 确认 PostgreSQL 健康检查通过

3. **Redis 认证失败**
   - 检查 `REDIS_PASSWORD` 一致性
   - 确认 Redis 容器正常运行

4. **HTTPS 证书申请失败**
   - 确认域名 DNS 解析正确
   - 80/443 端口未被占用
   - 防火墙允许入站连接

5. **更新后服务无法访问**
   - 查看健康检查状态
   - 检查最新日志输出
   - 必要时回滚到旧版本

### 日志位置
- **容器日志**: `docker compose logs -f <service>`
- **应用日志**: `./logs/<service>/`
- **Caddy 访问日志**: `./caddy_data/access.log`

### 备份建议
```bash
# 定期备份数据库
docker compose exec postgres pg_dump -U harborapi harborapi > backup.sql

# 备份 Redis
docker compose exec redis redis-cli --rdb /data/dump.rdb save
cp ./redis_data/dump.rdb backup/

# 备份配置
tar -czf harbor-backup-$(date +%Y%m%d).tar.gz .env docker-compose.yml
```
