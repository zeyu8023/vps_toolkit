# 🚀 VPS Toolkit 面板脚本

VPS Toolkit 是一个模块化的 Bash 工具面板，专为 Linux VPS 用户设计，旨在简化服务器管理流程。它集成了系统信息查看、Docker 管理、网络测试、内存与 Swap 管理、环境安装、日志记录等功能，支持图形化菜单操作，适合小白用户快速部署与维护服务器环境。

## 🧠 项目亮点

- ✅ 模块化架构：每个功能独立封装，便于维护与扩展  
- ✅ 图形化菜单界面：清晰的编号式菜单，支持键盘交互  
- ✅ 自动日志记录：所有操作自动写入日志文件，便于审计  
- ✅ Docker Compose 支持：自动识别项目路径与配置文件  
- ✅ 网络质量测试集成：一键运行常用 IP/网络质量检测脚本  
- ✅ 一键安装环境：快速部署常用工具与运行环境  
- ✅ 开源可定制：脚本结构清晰，便于二次开发与集成

## 🖼️ 面板预览

+------------------------------------------------------------+
| 🚀 VPS 管理工具面板  |  By XIAOYU                    |
+------------------------------------------------------------+
📊 内存使用：已用: 224Mi / 总: 979Mi  
💽 磁盘使用：37% 已用 / 总: 4.9G  
⚙️ CPU 使用率：0.0%  
──────────────────────────────────────────────────────────────  
 1. 查看系统信息 🖥️  
 2. 网络设置 🌐  
 3. Docker管理 🐳  
 4. 应用管理 📦  
 5. 内存管理 🧠  
 6. Swap管理 💾  
 7. SSL证书管理 🔐  
 8. 一键安装常用环境 🧰  
 9. 常用测试脚本功能 🧪  
10. 查看操作日志 📜  
11. 系统常用工具 🛠️  
12. 模块更新 🔄  
 0. 退出程序  
──────────────────────────────────────────────────────────────  
👉 请输入选项编号:  

## 📦 快速安装

```bash
bash <(curl -sSL https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/install.sh)
```

> 自动安装所有模块并创建快捷命令 `tool`

## 🛠️ 使用方式

运行主命令：

```bash
tool
```

进入图形化菜单界面，按编号选择功能模块。

## 📋 主菜单功能一览

| 编号 | 模块名称 | 功能描述 |
|------|-----------|-----------|
| 1 | 系统信息助手 🖥️ | 查看主机信息、CPU、内存、磁盘、服务状态  
| 2 | 网络设置中心 🌐 | 修改 DNS、测速、清理网络缓存、查看端口  
| 3 | Docker 管理中心 🐳 | 管理容器、镜像、Compose 项目、日志查看  
| 4 | 应用管理中心 📦 | 分类展示已安装应用，支持更新卸载  
| 5 | 内存管理中心 🧠 | 清理缓存、释放内存、查看内存占用  
| 6 | Swap 管理中心 💾 | 创建、删除、查看 Swap 分区  
| 7 | SSL 证书管理 🔐 | 一键申请、续签、吊销证书，自动处理端口冲突  
| 8 | 一键安装环境 🧰 | 安装常用工具如 curl、git、docker、htop  
| 9 | 常用测试脚本功能 🧪 | IP质量、网络质量、NodeQuality验证  
| 10 | 操作日志查看 📜 | 查看所有操作记录，支持清空、搜索  
| 11 | 系统常用工具 🛠️ | 端口查询、资源分析、垃圾清理、安全审计  
| 12 | 模块更新中心 🔄 | 检查远程版本、更新模块、版本对比提醒  

## 🔐 SSL 证书管理增强功能

- 自动检测端口 80 占用并提示终止进程  
- 智能识别服务名（nginx/apache2）并可恢复服务  
- 支持无邮箱申请、续签、吊销证书  
- 查看证书信息时显示 `.pem`、`.key` 路径  
- 所有操作自动记录日志

## 🐳 Docker 管理中心功能详解

- 状态高亮显示（绿色运行中 / 红色已停止）  
- 自动识别 Compose 项目并标记 🧩  
- 显示端口映射信息 🔌  
- 支持分页与编号选择操作  
- 启动 / 停止 / 卸载容器  
- 自动拉取镜像并更新容器  
- 保留原配置重新部署容器  
- 支持通过 Compose 更新项目（自动识别工作目录）  
- 创建项目自动生成目录并引导编辑配置  
- 编辑项目自动识别 `.yml` 文件并备份原配置

## 🧪 常用测试脚本功能

| 编号 | 测试项 | 命令 |
|------|--------|------|
| 1 | IP质量测试 | `bash <(curl -sL Check.Place) -I`  
| 2 | 网络质量检测 | `bash <(curl -sL Check.Place) -N`  
| 3 | NodeQuality验证 | `bash <(curl -sL https://run.NodeQuality.com)`  

鸣谢脚本作者：[@xykt](https://github.com/xykt)

## 📜 日志系统说明

- 所有模块调用 `log "操作描述"` 自动记录至 `vps_toolkit.log`  
- 日志文件路径：`/opt/vps_toolkit/logs/vps_toolkit.log`  
- 日志格式：`[YYYY-MM-DD HH:MM:SS] [模块名] 操作内容`  
- 支持查看最近日志、清空日志、模块化日志管理  
- 可扩展为远程推送日志到 Telegram、Webhook 等平台

## 🔄 模块更新中心增强功能

- 检查远程版本后提示是否立即更新所有模块  
- 所有更新行为记录日志  
- 支持查看当前版本、远程版本、更新指定模块  
- 支持版本对比与自动加载更新后的模块

---

## ☁️ 脚本收藏夹备份机制（多用户支持）

VPS Toolkit 支持将你的脚本收藏夹备份到公共 GitHub 仓库 [`vps-toolkit-scripts`](https://github.com/zeyu8023/vps-toolkit-scripts)，并支持从该仓库恢复脚本。

每个用户的脚本列表将存储在：

```
<GitHub用户名>/test_scripts.list
```

例如：

- `zeyu8023/test_scripts.list`
- `userA/test_scripts.list`

---

## 🚀 提交脚本收藏夹

在 VPS Toolkit 面板中选择：

```
9) 提交脚本到公共仓库 🚀
```

首次提交时会提示输入 GitHub Token（classic 类型，需 `repo` 权限），脚本将自动提交到仓库对应路径。

---

## 🔄 恢复脚本收藏夹

在 VPS Toolkit 面板中选择：

```
10) 从公共仓库恢复脚本 🔄
```

输入你的 GitHub 用户名后，脚本将自动拉取：

```
https://raw.githubusercontent.com/zeyu8023/vps-toolkit-scripts/master/<你的用户名>/test_scripts.list
```

并恢复到本地配置文件 `/opt/vps_toolkit/config/test_scripts.list`

---

## 🔐 如何获取 GitHub Token

1. 登录 GitHub：[https://github.com](https://github.com)
2. 打开 Token 页面：[https://github.com/settings/tokens](https://github.com/settings/tokens)
3. 点击 `Generate new token (classic)`
4. 设置名称、有效期，并勾选权限：
   - ✅ `repo`
5. 生成后复制 `ghp_...` 开头的 Token，粘贴到工具中

⚠️ 注意：Token 只显示一次，请妥善保存！

---

## 📁 当前已提交用户（示例）

- [`zeyu8023/test_scripts.list`](https://github.com/zeyu8023/vps-toolkit-scripts/blob/master/zeyu8023/test_scripts.list)
- [`userA/test_scripts.list`](https://github.com/zeyu8023/vps-toolkit-scripts/blob/master/userA/test_scripts.list)

你可以在仓库中浏览每个用户的脚本列表。

---

## 🤝 欢迎加入脚本共享计划

你可以提交自己的脚本收藏夹，与其他用户共享常用工具与测试命令。  
也可以恢复他人的脚本列表，快速获取实用脚本合集。

## 📎 项目地址

- GitHub 项目主页：https://github.com/zeyu8023/vps_toolkit

## 📬 联系与反馈

如有建议、Bug反馈或功能请求，欢迎提交 Issue 或 PR 到 GitHub 项目主页。  
也欢迎你 Fork 本项目并进行个性化定制，打造属于自己的 VPS 管理工具！
