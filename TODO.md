# HarborAPI 待办事项

## 🔥 高优先级

- [ ] **Logo 设计**
  - [ ] HarborAPI 主 Logo（PNG + SVG）
  - [ ] Favicon（16x16, 32x32）
  - [ ] 替换到 overlay 目录

- [ ] **GitHub 仓库设置**
  - [ ] 创建 GitHub 仓库 `xu158185/harbor-api`
  - [ ] 推送代码到远程
  - [ ] 配置 GitHub Secrets（DOCKERHUB_USERNAME, DOCKERHUB_TOKEN）
  - [ ] 启用 GitHub Actions

- [ ] **首次构建镜像**
  - [ ] 手动触发 GitHub Actions 构建
  - [ ] 验证镜像可用性
  - [ ] 推送到 GHCR 和 Docker Hub

- [ ] **生产部署测试**
  - [ ] 在真实 VPS 上测试部署
  - [ ] 验证 HTTPS 证书自动申请
  - [ ] 测试更新脚本

## 📋 中优先级

- [ ] **补丁完善**
  - [ ] 确认 new-api 前端如何正确应用 CSS 补丁
  - [ ] 确认 sub2api 前端如何隐藏更新按钮
  - [ ] 测试补丁在新版本中的兼容性

- [ ] **监控和告警**
  - [ ] 添加 Prometheus + Grafana（可选）
  - [ ] 配置邮件告警
  - [ ] 磁盘空间监控

- [ ] **备份自动化**
  - [ ] 编写自动备份脚本
  - [ ] 配置 cron 任务
  - [ ] 测试恢复流程

- [ ] **Web 管理面板**（可选）
  - [ ] 创建简单的更新管理界面
  - [ ] 显示服务状态
  - [ ] 一键更新按钮

## 🎨 低优先级

- [ ] **主题扩展**
  - [ ] 创建深色模式主题
  - [ ] 创建更多预设主题
  - [ ] 主题切换功能

- [ ] **文档完善**
  - [ ] 录制部署视频教程
  - [ ] 添加常见问题 FAQ
  - [ ] 多语言文档（英文版）

- [ ] **CI/CD 增强**
  - [ ] 自动化测试（health check）
  - [ ] 自动化发布 Release Notes
  - [ ] Dependabot 依赖更新

## ✅ 已完成

- [x] 初始化仓库结构
- [x] 编写 Docker Compose 配置
- [x] 创建部署脚本（install.sh, update.sh, generate-secrets.sh）
- [x] 编写 GitHub Actions 工作流
- [x] 设计 HarborAPI 主题（CSS）
- [x] 创建补丁文件
- [x] 编写架构文档
- [x] 编写部署指南
- [x] 编写贡献指南
- [x] 添加 LICENSE

## 💡 未来想法

- [ ] 支持 Kubernetes 部署（Helm Chart）
- [ ] 支持 Traefik 作为替代反向代理
- [ ] 添加 Web SSH 终端（管理容器）
- [ ] 集成日志聚合（Loki）
- [ ] 用户配额管理
- [ ] API 使用统计和可视化
