# 🚀 VPS Toolkit 面板脚本

VPS Toolkit 是一个模块化的 Bash 工具面板，专为 Linux VPS 用户设计，旨在简化服务器管理流程。它集成了系统信息查看、Docker 管理、网络测试、内存与 Swap 管理、环境安装、日志记录等功能，支持图形化菜单操作，适合技术用户快速部署与维护服务器环境。

---

## 🧠 项目亮点

- ✅ **模块化架构**：每个功能独立封装，便于维护与扩展  
- ✅ **图形化菜单界面**：清晰的编号式菜单，支持键盘交互  
- ✅ **自动日志记录**：所有操作自动写入日志文件，便于审计  
- ✅ **Docker Compose 支持**：自动识别项目路径与配置文件  
- ✅ **网络质量测试集成**：一键运行常用 IP/网络质量检测脚本  
- ✅ **一键安装环境**：快速部署常用工具与运行环境  
- ✅ **开源可定制**：脚本结构清晰，便于二次开发与集成

---

## 📦 快速安装

```bash
bash <(curl -sSL https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/install.sh)
```

> 自动安装所有模块并创建快捷命令 `tool`

---

## 🛠️ 使用方式

运行主命令：

```bash
tool
```

进入图形化菜单界面，按编号选择功能模块。

---

## 📋 主菜单功能一览

| 编号 | 模块名称 | 功能描述 |
|------|-----------|-----------|
| 1 | 系统信息助手 🖥️ | 查看主机信息、CPU、内存、磁盘、服务状态  
| 2 | 网络设置中心 🌐 | 修改 DNS、测速、清理网络缓存、查看端口  
| 3 | Docker 管理中心 🐳 | 管理容器、镜像、Compose 项目、日志查看  
| 4 | 内存管理中心 🧠 | 清理缓存、释放内存、查看内存占用  
| 5 | Swap 管理中心 💾 | 创建、删除、查看 Swap 分区  
| 6 | 一键安装环境 🧰 | 安装常用工具如 curl、git、docker、htop  
| 7 | 常用测试脚本功能 🧪 | IP质量、网络质量、NodeQuality验证  
| 8 | 操作日志查看 📜 | 查看所有操作记录，支持清空、搜索

---

## 🐳 Docker 管理中心功能详解

### 容器列表展示增强

- 状态高亮显示（绿色运行中 / 红色已停止）  
- 自动识别 Compose 项目并标记 🧩  
- 显示端口映射信息 🔌  
- 支持分页与编号选择操作

### 容器操作支持

- 启动 / 停止 / 卸载容器  
- 自动拉取镜像并更新容器  
- 保留原配置重新部署容器  
- 支持通过 Compose 更新项目（自动识别工作目录）

### 新建 Docker Compose 项目

- 输入项目名称后自动创建目录 `/opt/compose/<项目名>`  
- 提示用户手动编辑 `docker-compose.yml`  
- 指导使用 `nano` 编辑器：Ctrl+O 保存，Ctrl+X 退出  
- 检查配置文件是否为空，确认是否启动服务  
- 自动记录日志并标记项目路径

### 编辑正在运行的 Compose 项目

- 自动识别运行中的 Compose 项目列表  
- 提取真实工作目录（`com.docker.compose.project.working_dir`）  
- 自动识别 `.yml` 或 `.yaml` 配置文件  
- 支持备份原配置为 `.bak`  
- 编辑后自动重载服务并记录日志

---

## 🧪 常用测试脚本功能

进入菜单后可选择以下测试：

| 编号 | 测试项 | 命令 |
|------|--------|------|
| 1 | IP质量测试 | `bash <(curl -sL Check.Place) -I`  
| 2 | 网络质量检测 | `bash <(curl -sL Check.Place) -N`  
| 3 | NodeQuality验证 | `bash <(curl -sL https://run.NodeQuality.com)`  

### 鸣谢脚本作者

- 作者：[@xykt](https://github.com/xykt)  
- 感谢其提供高质量的网络测试脚本接口！

---

## 📜 日志系统说明

- 所有模块调用 `log "操作描述"` 自动记录至 `vps_toolkit.log`  
- 日志文件路径：`/opt/vps_toolkit/logs/vps_toolkit.log`  
- 日志格式：`[YYYY-MM-DD HH:MM:SS] 操作内容`  
- 支持查看最近日志、清空日志、模块化日志管理  
- 可扩展为远程推送日志到 Telegram、Webhook 等平台

---

## 📎 项目地址

- 主项目主页：[https://github.com/zeyu8023/vps_toolkit](https://github.com/zeyu8023/vps_toolkit)  
  
---

## 📬 联系与反馈

如有建议、Bug反馈或功能请求，欢迎提交 Issue 或 PR 到 GitHub 项目主页。  
也欢迎你 Fork 本项目并进行个性化定制，打造属于自己的 VPS 管理工具！
