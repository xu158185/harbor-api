# 🚀 快速开始（5 分钟部署）

## 适合初次使用者的快速指南

### 第 1 步：准备环境

确保你的服务器已安装 Docker：

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y docker.io docker-compose-plugin

# CentOS/RHEL
sudo yum install -y docker docker-compose-plugin

# 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 第 2 步：下载 HarborAPI

```bash
git clone https://github.com/xu158185/harbor-api.git
cd harbor-api
```

### 第 3 步：生成配置

```bash
./scripts/generate-secrets.sh
```

这会自动创建 `.env` 文件并生成所有安全密钥。

### 第 4 步：设置域名（可选）

**本地测试**：跳过此步骤，使用默认的 `localhost`

**生产部署**：编辑 `.env` 文件
```bash
nano .env
# 修改这一行：
DOMAIN=your-domain.com
```

> 💡 提示：确保域名已解析到服务器 IP

### 第 5 步：启动服务

```bash
./scripts/install.sh
```

等待 1-2 分钟，所有服务启动完成。

### 第 6 步：访问

打开浏览器访问：
- **API 网关**: `https://your-domain.com` （或 `http://localhost`）
- **管理后台**: `https://your-domain.com/admin`

首次访问会进入设置向导，按提示完成初始化。

## ✅ 完成！

现在你可以：
1. 在 new-api 中配置 AI 模型渠道
2. 在 sub2api 中管理订阅账号
3. 生成 API Key 开始使用

## 🔄 日常使用

### 查看服务状态
```bash
docker compose ps
```

### 查看日志
```bash
docker compose logs -f new-api
docker compose logs -f sub2api
```

### 更新服务
```bash
# 更新 new-api
./scripts/update.sh new-api

# 更新 sub2api
./scripts/update.sh sub2api
```

### 停止服务
```bash
docker compose stop
```

### 重启服务
```bash
docker compose restart
```

## ❓ 遇到问题？

1. 检查日志：`docker compose logs`
2. 查看 [部署指南](DEPLOYMENT.md) 的故障排查章节
3. 提交 [Issue](https://github.com/xu158185/harbor-api/issues)

## 📚 深入了解

- [完整部署指南](DEPLOYMENT.md) - 详细配置和维护
- [架构说明](ARCHITECTURE.md) - 技术细节和原理
- [自定义品牌](ARCHITECTURE.md#品牌定制) - 修改主题和 Logo
