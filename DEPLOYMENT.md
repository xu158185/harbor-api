# HarborAPI 部署指南

## 前置要求

- Docker 20.10+
- Docker Compose v2.0+
- 域名（可选，本地测试用 localhost）
- 服务器最低配置：1 核 1GB 内存

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/xu158185/harbor-api.git
cd harbor-api
```

### 2. 生成配置文件

```bash
./scripts/generate-secrets.sh
```

这会创建 `.env` 文件并自动生成所有密钥。

### 3. 编辑配置

```bash
nano .env
```

**必须修改的配置**:
- `DOMAIN`: 改为你的域名（例如 `api.example.com`），本地测试用 `localhost`

**可选修改**:
- `ADMIN_EMAIL`: 管理员邮箱
- `ADMIN_PASSWORD`: 管理员密码（留空时会在首次启动时设置）
- `TZ`: 时区（默认 `Asia/Shanghai`）

### 4. 启动服务

```bash
./scripts/install.sh
```

脚本会自动：
1. 拉取 Docker 镜像
2. 启动所有服务
3. 等待健康检查通过

### 5. 访问服务

- **API 网关**: `https://your-domain.com`
- **管理后台**: `https://your-domain.com/admin`

首次访问时按照向导完成初始化设置。

## 更新服务

### 更新单个服务

```bash
# 只更新 new-api
./scripts/update.sh new-api

# 只更新 sub2api
./scripts/update.sh sub2api
```

### 更新所有服务

```bash
./scripts/update.sh all
```

更新脚本会自动：
1. 拉取最新镜像
2. 重启服务
3. 健康检查
4. 失败时显示日志

## 日常维护

### 查看日志

```bash
# 查看所有服务日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f new-api
docker compose logs -f sub2api
```

### 停止服务

```bash
docker compose stop
```

### 重启服务

```bash
# 重启所有服务
docker compose restart

# 重启单个服务
docker compose restart new-api
```

### 备份数据

```bash
# 备份数据库
docker compose exec postgres pg_dump -U harborapi harborapi > backup-$(date +%Y%m%d).sql

# 备份 Redis
docker compose exec redis redis-cli --rdb /data/dump.rdb save
cp ./redis_data/dump.rdb backup/

# 备份配置
tar -czf harbor-backup-$(date +%Y%m%d).tar.gz .env docker-compose.yml
```

### 恢复数据库

```bash
# 从备份恢复
docker compose exec -T postgres psql -U harborapi harborapi < backup-20240101.sql
```

## 故障排查

### 服务启动失败

1. 检查日志：
   ```bash
   docker compose logs <service-name>
   ```

2. 检查容器状态：
   ```bash
   docker compose ps
   ```

3. 验证配置：
   ```bash
   cat .env | grep -v '^#' | grep -v '^$'
   ```

### 数据库连接错误

- 确认 `POSTGRES_PASSWORD` 在 `.env` 中已设置
- 检查 PostgreSQL 容器健康状态：
  ```bash
  docker compose ps postgres
  ```

### HTTPS 证书问题

- 确认域名 DNS 已正确解析到服务器
- 确认防火墙开放 80 和 443 端口
- 查看 Caddy 日志：
  ```bash
  docker compose logs caddy
  ```

### 内存不足

如果服务器内存小于 1GB，考虑：
1. 添加 swap 空间
2. 限制容器内存使用（编辑 `docker-compose.yml`）

## 高级配置

### 使用自定义域名

编辑 `.env`:
```env
DOMAIN=api.yourdomain.com
```

重启服务:
```bash
docker compose restart caddy
```

### 配置代理（国内服务器）

如果需要通过代理访问 GitHub（检查更新用），编辑 `.env`:
```env
UPDATE_PROXY_URL=http://127.0.0.1:7890
```

### 启用 GitHub Token（避免 rate limit）

1. 访问 https://github.com/settings/tokens
2. 生成 Personal Access Token（只需 `public_repo` 权限）
3. 添加到 `.env`:
   ```env
   UPDATE_GITHUB_TOKEN=ghp_xxxxxxxxxxxx
   ```

### 修改绑定地址（生产环境）

生产环境建议只允许来自 Caddy 的请求，编辑 `.env`:
```env
BIND_HOST=127.0.0.1
```

这样应用容器只监听本地回环地址，必须通过 Caddy 访问。

## 自定义品牌

### 修改 Logo

1. 准备你的 Logo 文件：
   - new-api: `new-api/overlay/web/public/logo-harbor.png`
   - sub2api: `sub2api/overlay/frontend/public/logo-harbor.svg`

2. 重新构建镜像（需要 GitHub Actions 或本地 Docker build）

### 修改主题颜色

编辑 `new-api/overlay/web/src/styles/harbor-theme.css`，修改 CSS 变量：

```css
:root {
  --harbor-terracotta: #C4612F;  /* 主色调 */
  --harbor-cream: #F7F4EF;       /* 背景色 */
  /* ... */
}
```

## 性能优化

### 启用 Redis 持久化

已默认启用 AOF（Append Only File）持久化，每秒同步一次。

### 数据库连接池

new-api 和 sub2api 都内置了连接池，无需额外配置。

### 日志轮转

Caddy 日志自动轮转（100MB 一个文件，保留 5 个）。

应用日志需要手动清理或配置 logrotate。

## 安全建议

1. **使用强密码**: 运行 `generate-secrets.sh` 自动生成
2. **定期更新**: 每周运行 `update.sh` 检查更新
3. **备份数据**: 设置 cron 任务定期备份数据库
4. **监控日志**: 定期检查异常登录和 API 调用
5. **限制访问**: 生产环境设置 `BIND_HOST=127.0.0.1`

## 卸载

```bash
# 停止并删除所有容器
docker compose down

# 删除数据卷（⚠️ 会丢失所有数据）
rm -rf postgres_data redis_data data logs caddy_data caddy_config

# 删除配置文件
rm .env

# 删除整个目录
cd ..
rm -rf harbor-api
```

## 支持

- **问题反馈**: https://github.com/xu158185/harbor-api/issues
- **上游项目**:
  - new-api: https://github.com/QuantumNous/new-api
  - sub2api: https://github.com/Wei-Shaw/sub2api
