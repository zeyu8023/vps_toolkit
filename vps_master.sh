#!/bin/bash
# 🚀 VPS Toolkit 主菜单脚本 | By XIAOYU

SCRIPT_DIR="/opt/vps_toolkit"
MODULE_DIR="$SCRIPT_DIR/modules"
LOG_FILE="$SCRIPT_DIR/logs/vps_toolkit.log"

# ✅ 通用日志函数
log() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $*" >> "$LOG_FILE"
}
export -f log

# ✅ 模块函数映射表
declare -A modules=(
  [1]="system_info.sh:system_info"
  [2]="network_tools.sh:network_tools"
  [3]="docker_tools.sh:docker_management_center"
  [4]="app_manager.sh:app_manager"
  [5]="memory_tools.sh:memory_management_center"
  [6]="swap_tools.sh:swap_management_center"
  [7]="install_tools.sh:install_tools"
  [8]="test_tools.sh:test_tools"
  [9]="log_tools.sh:log_tools"
  [10]="system_tools.sh:system_tools"
)

# ✅ 加载所有模块
for key in "${!modules[@]}"; do
  IFS=":" read -r file func <<< "${modules[$key]}"
  path="$MODULE_DIR/$file"
  if [[ -f "$path" ]]; then
    source "$path"
    if ! declare -F "$func" >/dev/null; then
      echo "❌ 模块 $file 加载失败：未定义函数 $func"
      exit 1
    fi
  else
    echo "❌ 模块文件缺失：$file"
    exit 1
  fi
done

# ✅ 主菜单循环
while true; do
  clear

  # 🎨 颜色定义
  GREEN="\033[1;32m"
  BLUE="\033[1;34m"
  YELLOW="\033[1;33m"
  RESET="\033[0m"

  # 📐 标题宽度
  width=60
  title="🚀 VPS 管理工具面板  |  By XIAOYU"

  # 🔷 打印 ASCII 标题框（兼容所有终端）
  printf "${BLUE}+%${width}s+${RESET}\n" | tr ' ' '-'
  printf "${BLUE}| %-${width}s |${RESET}\n" "$title"
  printf "${BLUE}+%${width}s+${RESET}\n" | tr ' ' '-'

  # 📊 系统状态信息
  mem_used=$(free -m | awk '/Mem:/ {print $3}')
  mem_total=$(free -m | awk '/Mem:/ {print $2}')
  disk_used=$(df -h / | awk 'NR==2 {print $5}')
  disk_total=$(df -h / | awk 'NR==2 {print $2}')
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1}')
  cpu_usage=$(printf "%.1f" "$cpu_usage")

  printf "${GREEN}📊 内存使用：已用: %sMi / 总: %sMi${RESET}\n" "$mem_used" "$mem_total"
  printf "${GREEN}💽 磁盘使用：%s 已用 / 总: %s${RESET}\n" "$disk_used" "$disk_total"
  printf "${GREEN}⚙️ CPU 使用率：${cpu_usage}%%${RESET}\n"

  # 📋 菜单项
  printf "${YELLOW}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width+2))))"
  printf "${YELLOW} 1.${RESET} 查看系统信息 🖥️\n"
  printf "${YELLOW} 2.${RESET} 网络设置 🌐\n"
  printf "${YELLOW} 3.${RESET} Docker 管理 🐳\n"
  printf "${YELLOW} 4.${RESET} 应用管理 📦\n"
  printf "${YELLOW} 5.${RESET} 内存管理 🧠\n"
  printf "${YELLOW} 6.${RESET} Swap 管理 💾\n"
  printf "${YELLOW} 7.${RESET} 一键安装常用环境 🧰\n"
  printf "${YELLOW} 8.${RESET} 常用测试脚本功能 🧪\n"
  printf "${YELLOW} 9.${RESET} 查看操作日志 📜\n"
  printf "${YELLOW}10.${RESET} 系统常用工具 🛠️\n"
  printf "${YELLOW} 0.${RESET} 退出程序\n"
  printf "${YELLOW}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 $((width+2))))"

  # 🔽 用户输入
  read -p "$(echo -e "${BLUE}👉 请输入选项编号: ${RESET}")" choice

  if [[ "$choice" == "0" ]]; then
    echo -e "${GREEN}👋 再见！${RESET}" && exit 0
  elif [[ -n "${modules[$choice]}" ]]; then
    IFS=":" read -r _ func <<< "${modules[$choice]}"
    "$func"
  else
    echo -e "${YELLOW}❌ 无效选项，请重新输入。${RESET}" && sleep 1
  fi
done
