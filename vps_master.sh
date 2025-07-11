#!/bin/bash

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

log() {
  echo "$(date '+%F %T') $1" >> "$LOG_FILE"
}

# 加载模块
for module in /opt/vps_toolkit/modules/*.sh; do
  source "$module"
done

# 主菜单显示
show_menu() {
  clear
  echo -e "\033[1;36m╔════════════════════════════════════════════════════╗"
  echo -e "║         🚀 VPS 管理工具面板  |  By XIAOYU           ║"
  echo -e "╚════════════════════════════════════════════════════╝\033[0m"

  echo -e "\033[1;37m📊 内存使用：\033[0m$(free -h | awk '/Mem:/ {print "已用: "$3" / 总: "$2}')"
  echo -e "\033[1;37m💽 磁盘使用：\033[0m$(df -h / | awk 'NR==2 {print $5" 已用 / 总: "$2}')"
  echo -e "\033[1;37m⚙️ 系统负载：\033[0m$(uptime | awk -F'load average:' '{print $2}')"
  echo -e "\033[90m────────────────────────────────────────────────────\033[0m"

  echo -e "\033[1;34m 1.\033[0m 查看详细内存信息"
  echo -e "\033[1;34m 2.\033[0m 查看高内存进程并可选择终止"
  echo -e "\033[1;34m 3.\033[0m 释放缓存内存"
  echo -e "\033[1;34m 4.\033[0m 卸载指定程序"
  echo -e "\033[1;34m 5.\033[0m 设置自动缓存清理任务"
  echo -e "\033[1;34m 6.\033[0m 查看操作日志"
  echo -e "\033[1;34m 7.\033[0m 启用 Swap（自定义大小）"
  echo -e "\033[1;34m 8.\033[0m 删除 Swap"
  echo -e "\033[1;34m 9.\033[0m 内存分析助手 🧠"
  echo -e "\033[1;34m10.\033[0m 程序/服务搜索助手 🔍"
  echo -e "\033[1;34m11.\033[0m 查看系统信息 🖥️"
  echo -e "\033[1;34m12.\033[0m 一键安装常用环境（可选组件）🧰"
  echo -e "\033[1;34m13.\033[0m 网络设置中心 🌐"
  echo -e "\033[1;34m14.\033[0m Docker 管理中心 🐳"
  echo -e "\033[1;34m 0.\033[0m 退出程序"
  echo -e "\033[90m────────────────────────────────────────────────────\033[0m"
}

# 主循环
while true; do
  show_menu
  read -p "👉 请输入选项编号: " choice
  case $choice in
    1) show_memory_info ;;
    2) manage_memory_processes ;;
    3) clear_memory_cache ;;
    4) uninstall_program ;;
    5) setup_auto_cache_clear ;;
    6) tail -n 20 "$LOG_FILE" ;;
    7) enable_swap ;;
    8) disable_swap ;;
    9) memory_analysis ;;
    10) search_program ;;
    11) show_system_info ;;
    12) install_environment_menu ;;
    13) network_settings_menu ;;
    14) docker_management_center ;;
    0) echo "👋 再见，感谢使用 VPS Toolkit！"; exit 0 ;;
    *) echo "❌ 无效选项，请重新输入" ;;
  esac
  read -p "按回车键返回主菜单..."
done
