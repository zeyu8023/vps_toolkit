#!/bin/bash

LOG_FILE="/var/log/vps_toolkit.log"

log() {
  echo "$(date '+%F %T') $1" >> "$LOG_FILE"
}

# ==========================
# VPS 工具主菜单
# ==========================
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
  echo -e "\033[1;34m 2.\033[0m 查看并终止进程（按内存排序）"
  echo -e "\033[1;34m 3.\033[0m 释放缓存内存"
  echo -e "\033[1;34m 4.\033[0m 卸载指定程序"
  echo -e "\033[1;34m 5.\033[0m 设置自动缓存清理任务"
  echo -e "\033[1;34m 6.\033[0m 查看操作日志"
  echo -e "\033[1:34m 7.\033[0m 启用 Swap（自定义大小）"
  echo -e "\033[1:34m 8.\033[0m 删除 Swap"
  echo -e "\033[1:34m 9.\033[0m 内存分析助手 🧠"
  echo -e "\033[1:34m10.\033[0m 程序/服务搜索助手 🔍"
  echo -e "\033[1:34m11.\033[0m 查看系统信息 🖥️"
  echo -e "\033[1:34m12.\033[0m 一键安装常用环境（可选组件）🧰"
  echo -e "\033[1:34m 0.\033[0m 退出程序"
  echo -e "\033[90m────────────────────────────────────────────────────\033[0m"
}

# ==========================
# 多级交互式安装器主菜单
# ==========================
install_environment_menu() {
  while true; do
    echo -e "\n🧰 请选择要安装的环境类型："
    echo "--------------------------------------------"
    echo " 1) 系统工具"
    echo " 2) 网络工具"
    echo " 3) 编译环境"
    echo " 4) Python 环境"
    echo " 5) Node.js 环境"
    echo " 6) Web 服务"
    echo " 7) Docker 环境"
    echo " 0) 返回主菜单"
    echo "--------------------------------------------"
    read -p "👉 请输入编号: " env_choice

    case $env_choice in
      1) install_system_tools ;;
      2) install_network_tools ;;
      3) install_build_tools ;;
      4) install_python_tools ;;
      5) install_nodejs_tools ;;
      6) install_web_stack ;;
      7) install_docker_tools ;;
      0) break ;;
      *) echo "❌ 无效选择，请重新输入" ;;
    esac
  done
}

# ==========================
# 子菜单函数（各类环境）
# ==========================
install_system_tools() {
  declare -A map=(
    [1]="curl"
    [2]="wget"
    [3]="git"
    [4]="vim"
    [5]="htop"
    [6]="ufw"
  )
  prompt_and_install "系统工具" map
}

install_network_tools() {
  declare -A map=(
    [1]="net-tools"
    [2]="dnsutils"
    [3]="nmap"
    [4]="iperf3"
  )
  prompt_and_install "网络工具" map
}

install_build_tools() {
  declare -A map=(
    [1]="build-essential"
    [2]="gcc"
    [3]="make"
    [4]="cmake"
  )
  prompt_and_install "编译环境" map
}

install_python_tools() {
  declare -A map=(
    [1]="python3"
    [2]="python3-pip"
    [3]="virtualenv"
  )
  prompt_and_install "Python 环境" map
}

install_nodejs_tools() {
  declare -A map=(
    [1]="nodejs"
    [2]="npm"
  )
  prompt_and_install "Node.js 环境" map
}

install_web_stack() {
  declare -A map=(
    [1]="nginx"
    [2]="apache2"
    [3]="php"
    [4]="mysql-server"
  )
  prompt_and_install "Web 服务" map
}

install_docker_tools() {
  declare -A map=(
    [1]="docker.io"
    [2]="docker-compose"
  )
  prompt_and_install "Docker 环境" map
  systemctl enable docker && systemctl start docker
}

prompt_and_install() {
  local title="$1"
  declare -n options=$2

  echo -e "\n🧩 $title 安装菜单：请选择要安装的组件（用空格分隔）"
  echo "--------------------------------------------"
  for i in "${!options[@]}"; do
    echo " $i) ${options[$i]}"
  done
  echo " 0) 返回上一级"
  echo "--------------------------------------------"
  read -p "👉 请输入编号（如 1 3 5）: " choices

  [[ "$choices" =~ (^| )0($| ) ]] && return

  to_install=""
  for i in $choices; do
    [[ -n "${options[$i]}" ]] && to_install+="${options[$i]} "
  done

  if [[ -z "$to_install" ]]; then
    echo "⚠️ 没有有效选择，已取消"
    return
  fi

  echo -e "\n📦 正在安装：$to_install"
  if command -v apt >/dev/null; then
    apt update && apt install -y $to_install
  elif command -v yum >/dev/null; then
    yum install -y $to_install
  else
    echo "❌ 不支持的包管理器"
    return
  fi

  echo "✅ 安装完成！"
  log "安装 $title：$to_install"
}

# ==========================
# 主程序循环
# ==========================
while true; do
  show_menu
  read -p "👉 请输入选项编号: " choice
  case $choice in
    1)
      echo -e "\n📊 内存详情："
      free -h
      ;;
    2)
      echo -e "\n📋 高内存占用进程："
      ps aux --sort=-%mem | head -n 15
      ;;
    3)
      echo -e "\n🧹 正在释放缓存..."
      sync; echo 3 > /proc/sys/vm/drop_caches
      echo "✅ 缓存已释放"
      ;;
    4)
      read -p "请输入要卸载的程序名: " pkg
      if command -v apt >/dev/null; then
        apt remove -y "$pkg"
      elif command -v yum >/dev/null; then
        yum remove -y "$pkg"
      fi
      ;;
    5)
      echo "0 * * * * root sync; echo 3 > /proc/sys/vm/drop_caches" > /etc/cron.d/clear_cache
      echo "✅ 已设置每小时自动清理缓存"
      ;;
    6)
      echo -e "\n📜 最近日志："
      tail -n 20 "$LOG_FILE"
      ;;
    7)
      read -p "请输入 Swap 大小（MB）: " size
      fallocate -l ${size}M /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo "/swapfile none swap sw 0 0" >> /etc/fstab
      echo "✅ Swap 启用成功"
      ;;
    8)
      swapoff /swapfile && rm -f /swapfile
      sed -i '/swapfile/d' /etc/fstab
      echo "✅ Swap 已删除"
      ;;
    9)
      echo -e "\n📊 内存分析助手（前 10 个进程）："
      ps aux --sort=-%mem | awk 'NR<=10{print $0}'
      ;;
    10)
      read -p "请输入程序或服务名关键词: " keyword
      echo -e "\n🔍 搜索结果："
      which "$keyword" 2>/dev/null && echo "✅ 可执行文件路径：$(which "$keyword")"
      systemctl status "$keyword" 2>/dev/null | head -n 10 && echo "✅ systemd 服务状态已显示"
      apt list --installed 2>/dev/null | grep "$keyword" && echo "✅ 已安装的软件包匹配"
      ;;
    11)
      echo -e "\n🖥️ 系统信息："
      echo "--------------------------------------------"
      echo "主机名：$(hostname)"
      echo "操作系统：$(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
      echo "内核版本：$(uname -r)"
      echo "CPU：$(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
      echo "内存总量：$(free -h | awk '/Mem:/ {print $2}')"
      echo "公网 IP：$(curl -s ifconfig.me)"
      echo "--------------------------------------------"
      ;;
    12)
      install_environment_menu
      ;;
    0)
      echo "👋 再见，感谢使用 VPS Toolkit！"
      exit 0
      ;;
    *)
      echo "❌ 无效选项，请重新输入"
      ;;
  esac

  echo -e "\n按回车键返回主菜单..."
  read
done
