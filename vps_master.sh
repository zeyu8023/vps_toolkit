#!/bin/bash
# 🚀 VPS 管理工具面板 | By XIAOYU

# ✅ 加载模块函数
MODULE_DIR="$(dirname "$0")/modules"

source "$MODULE_DIR/system_info.sh"
source "$MODULE_DIR/network_tools.sh"
source "$MODULE_DIR/docker_tools.sh"
source "$MODULE_DIR/memory_tools.sh"
source "$MODULE_DIR/swap_tools.sh"
source "$MODULE_DIR/install_tools.sh"
source "$MODULE_DIR/log_tools.sh"

# ✅ 主循环
while true; do
  clear
  echo "╔════════════════════════════════════════════════════╗"
  echo "║         🚀 VPS 管理工具面板  |  By XIAOYU           ║"
  echo "╚════════════════════════════════════════════════════╝"

  mem_used=$(free -m | awk '/Mem:/ {print $3}')
  mem_total=$(free -m | awk '/Mem:/ {print $2}')
  disk_used=$(df -h / | awk 'NR==2 {print $5}')
  disk_total=$(df -h / | awk 'NR==2 {print $2}')
  load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')

  echo "📊 内存使用：已用: ${mem_used}Mi / 总: ${mem_total}Mi"
  echo "💽 磁盘使用：${disk_used} 已用 / 总: ${disk_total}"
  echo "⚙️ 系统负载：${load_avg}"
  echo "────────────────────────────────────────────────────"
  echo " 1. 查看系统信息 🖥️"
  echo " 2. 网络设置中心 🌐"
  echo " 3. Docker 管理中心 🐳"
  echo " 4. 内存管理中心 🧠"
  echo " 5. Swap 管理中心 💾"
  echo " 6. 一键安装常用环境（可选组件）🧰"
  echo " 7. 查看操作日志 📜"
  echo " 0. 退出程序"
  echo "────────────────────────────────────────────────────"
  read -p "👉 请输入选项编号: " choice

  case "$choice" in
    1) system_info ;;
    2) network_tools ;;
    3) docker_management_center ;;
    4) memory_management_center ;;
    5) swap_management_center ;;
    6) install_tools ;;
    7) log_tools ;;
    0) echo "👋 再见！" && exit 0 ;;
    *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
  esac
done
