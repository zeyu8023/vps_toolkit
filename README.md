# 🚀 VPS Toolkit

一个模块化的 VPS 管理工具集，专为自动化、可扩展性和可靠性设计。适用于 VPS 运维、服务部署、网络优化等场景。支持 Docker 管理、系统信息查看、内存管理、环境安装、网络设置，优化等常用任务。

---

## 📦 一键安装

bash <(curl -sSL https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/install.sh)

安装完成后，可使用快捷命令：

tool

---

## 🖥️ 主控制面板预览

╔════════════════════════════════════════════════════╗  
║         🚀 VPS 管理工具面板  |  By XIAOYU           ║  
╚════════════════════════════════════════════════════╝  
📊 内存使用：已用: 892Mi / 总: 960Mi  
💽 磁盘使用：22% 已用 / 总: 46G  
⚙️ 系统负载： 0.02, 0.11, 0.10  
────────────────────────────────────────────────────  
 1. 查看详细内存信息  
 2. 查看高内存进程并可选择终止  
 3. 释放缓存内存  
 4. 卸载指定程序  
 5. 设置自动缓存清理任务  
 6. 查看操作日志  
 7. 启用 Swap（自定义大小）  
 8. 删除 Swap  
 9. 内存分析助手 🧠  
10. 程序/服务搜索助手 🔍  
11. 查看系统信息 🖥️  
12. 一键安装常用环境（可选组件）🧰  
13. 网络设置中心 🌐  
14. Docker 管理中心 🐳  
 0. 退出程序  
────────────────────────────────────────────────────  
👉 请输入选项编号:  

---

## 🧩 模块功能列表

模块名称             | 功能描述
----------------------|------------------------------------------------
system_info.sh        | 查看系统信息（CPU、内存、磁盘、网络）
memory_tools.sh       | 内存清理与缓存释放
swap_tools.sh         | 创建与管理 SWAP 分区
network_tools.sh      | 网络测速、IP 优化、CloudflareSpeedTest
docker_tools.sh       | Docker 容器管理中心（支持 Compose）
install_tools.sh      | 常用软件一键安装（Nginx、Xray 等）
uninstall_tools.sh    | 软件卸载与清理
ssl_tools.sh          | SSL 证书申请与自动续签（支持 ACME） *(可选)*

---

## 🐳 Docker 管理中心界面预览

🐳 Docker 容器管理中心：
--------------------------------------------
0) wxchat           —  ddsderek/wxchat:latest           —  Up 2 minutes   —  🔌 80/tcp → 0.0.0.0:8011  
1) npm-app-1        —  jc21/nginx-proxy-manager:latest  —  Up 14 minutes 🧩 Compose  —  🔌 80/tcp → 0.0.0.0:80, 443/tcp → 0.0.0.0:443  
2) nezha-dashboard  —  ghcr.io/nezhahq/nezha            —  Up 30 hours   🧩 Compose  —  🔌 443/tcp → 0.0.0.0:443  
--------------------------------------------
a) 清理无效容器  
0) 返回主菜单  
👉 请输入容器编号进行管理（直接回车退出）:

---

## 🛠️ 脚本操作页面预览

示例：更新容器

📦 正在拉取最新镜像：ddsderek/wxchat:latest  
Status: Image is up to date for ddsderek/wxchat:latest  

🔍 正在提取原容器配置...  
环境变量：-e TZ=Asia/Shanghai  
挂载卷：-v /etc/letsencrypt:/etc/letsencrypt  
端口映射：-p 0.0.0.0:8011:80/tcp  

🛑 停止并删除旧容器...  
✅ 容器 wxchat 已删除  

🚀 使用原配置重新启动容器...  
✅ 容器 wxchat 已更新并重启

---

示例：查看容器日志

📜 容器 wxchat 的最近日志：
[INFO] Starting service...  
[INFO] Listening on port 8011  
[INFO] Ready to accept connections

---

## 📁 项目结构示例

vps_toolkit/
├── install.sh              # 安装入口脚本
├── vps_master.sh           # 主控制面板
├── modules/
│   ├── docker_tools.sh
│   ├── install_tools.sh
│   ├── memory_tools.sh
│   ├── network_tools.sh
│   ├── swap_tools.sh
│   ├── system_info.sh
│   ├── uninstall_tools.sh
│   └── ssl_tools.sh
├── logs/
│   └── vps_toolkit.log
└── README.md

---

## 📌 更新日志

### [v1.2.0] - 2025-07-11

✨ 新增功能：
- 自动识别 docker-compose 管理容器
- 支持项目路径标签 `com.docker.compose.project.working_dir`
- 容器列表显示端口映射（支持 IPv4 / IPv6 / 多端口）
- 更新容器时保留原配置（环境变量、挂载卷、端口）
- 更新前配置预览
- 查看容器日志功能
- 一键清理无效容器

🛠️ 优化改进：
- 修复更新后容器端口丢失问题
- 自动过滤无名称或无镜像的容器
- 容器列表标记 Compose 管理容器
- 镜像拉取状态提示更清晰

---

## 🧠 作者 & 贡献

由 zeyu8023 构建，欢迎提交 Issue 或 PR 改进功能。

---

## 🛡️ License

MIT License
