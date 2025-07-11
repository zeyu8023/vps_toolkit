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
  echo -e "\033[1;34m 2.\033[0m 查看高内存进程并可选择终止"
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
  echo -e "\033[1;34m13.\033[0m 网络设置中心 🌐"
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

  # 清空上一次的选择记录
  to_install=""

  prompt_and_install "Docker 环境" map

  # 仅当用户选择了 docker.io 时才启动服务
  if [[ "$to_install" == *"docker.io"* ]]; then
    echo -e "\n🔧 正在启动并设置 Docker 开机自启..."
    systemctl enable docker && systemctl start docker
  fi
}

prompt_and_install() {
  local title="$1"
  declare -n options=$2

  echo -e "\n🧩 $title 安装菜单：请选择要安装的组件（用空格分隔）"
  echo "--------------------------------------------"

  # 检测包管理器
  local pkg_mgr=""
  if command -v apt >/dev/null; then
    pkg_mgr="apt"
  elif command -v yum >/dev/null; then
    pkg_mgr="yum"
  else
    echo "❌ 不支持的包管理器"
    return
  fi

  # 显示菜单并检测安装状态
  for i in "${!options[@]}"; do
    local pkg="${options[$i]}"
    local status=""

    if command -v "$pkg" >/dev/null 2>&1; then
      status="\033[1;32m✅（已安装）\033[0m"
    elif [[ "$pkg_mgr" == "apt" ]] && dpkg -l | grep -qw "$pkg"; then
      status="\033[1;32m✅（已安装）\033[0m"
    elif [[ "$pkg_mgr" == "yum" ]] && rpm -q "$pkg" >/dev/null 2>&1; then
      status="\033[1;32m✅（已安装）\033[0m"
    fi

    echo -e " $i) $pkg $status"
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
  if [[ "$pkg_mgr" == "apt" ]]; then
    apt update && apt install -y $to_install
  elif [[ "$pkg_mgr" == "yum" ]]; then
    yum install -y $to_install
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
     echo -e "\n📋 高内存占用进程（前 15 个）："
     echo "--------------------------------------------"
     ps -eo pid,comm,rss --sort=-rss | awk 'NR==1{printf "%-4s %-8s %-25s %-10s\n", "No.", "PID", "COMMAND", "MEM(MiB)"; next}
     {printf "%-4d %-8d %-25s %-10.2f\n", NR-1, $1, $2, $3/1024}' | head -n 16
     echo "--------------------------------------------"
     read -p "👉 输入要终止的 PID（留空跳过）: " pid
     if [[ -n "$pid" ]]; then
       kill -9 "$pid" && echo "✅ 已终止进程 $pid" || echo "❌ 无法终止进程 $pid"
       log "终止进程：PID $pid"
     else
       echo "🚫 未输入 PID，未执行终止操作"
     fi
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
    13)
      network_settings_menu
      ;;
    0)
      echo "👋 再见，感谢使用 VPS Toolkit！"
      exit 0
      ;;
    *)
      echo "❌ 无效选项，请重新输入"
      ;;
  esac

network_settings_menu() {
  while true; do
    echo -e "\n🌐 网络设置中心："
    echo "--------------------------------------------"
    echo " 1) 查看当前 IP 信息"
    echo " 2) 设置静态 IP 地址"
    echo " 3) 配置 DNS 服务器"
    echo " 4) 编辑 /etc/hosts 文件"
    echo " 5) 开关 IPv6"
    echo " 6) 安装/管理 Cloudflare WARP"
    echo " 0) 返回主菜单"
    echo "--------------------------------------------"
    read -p "👉 请输入编号: " net_choice

    case $net_choice in
      1) show_ip_info ;;
      2) set_static_ip ;;
      3) configure_dns ;;
      4) edit_hosts ;;
      5) toggle_ipv6 ;;
      6) manage_warp ;;
      0) break ;;
      *) echo "❌ 无效选择，请重新输入" ;;
    esac
  done
}

show_ip_info() {
  echo -e "\n🌐 当前 IP 信息："
  echo "--------------------------------------------"
  echo "公网 IPv4：$(curl -s ifconfig.me)"
  echo "公网 IPv6：$(curl -s https://api64.ipify.org)"
  echo "内网地址："
  ip -4 a | grep inet | awk '{print $2}' | grep -v 127.0.0.1
  echo "--------------------------------------------"
}

set_static_ip() {
  read -p "请输入网卡名称（如 eth0）: " iface
  read -p "请输入静态 IP 地址（如 192.168.1.100/24）: " ipaddr
  read -p "请输入网关地址（如 192.168.1.1）: " gateway

  ip addr flush dev "$iface"
  ip addr add "$ipaddr" dev "$iface"
  ip route add default via "$gateway"
  echo "✅ 静态 IP 设置完成（临时生效）"
}

configure_dns() {
  read -p "请输入 DNS 服务器地址（如 8.8.8.8）: " dns
  echo "nameserver $dns" > /etc/resolv.conf
  echo "✅ DNS 已设置为 $dns"
}

edit_hosts() {
  echo -e "\n📄 当前 /etc/hosts 内容："
  cat /etc/hosts
  echo "--------------------------------------------"
  read -p "是否编辑 hosts 文件？(y/N): " confirm
  [[ "$confirm" == "y" || "$confirm" == "Y" ]] && nano /etc/hosts
}

toggle_ipv6() {
  status=$(sysctl net.ipv6.conf.all.disable_ipv6 | awk '{print $3}')
  if [[ "$status" == "1" ]]; then
    sysctl -w net.ipv6.conf.all.disable_ipv6=0
    echo "✅ IPv6 已启用"
  else
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    echo "🚫 IPv6 已禁用"
  fi
}

manage_warp() {
  echo -e "\n⚡ WARP 管理器："
  echo "--------------------------------------------"
  echo " 1) 安装 WARP（warp-go）"
  echo " 2) 启动 WARP"
  echo " 3) 停止 WARP"
  echo " 4) 查看状态"
  echo " 0) 返回上一级"
  echo "--------------------------------------------"
  read -p "👉 请输入编号: " warp_choice

  case $warp_choice in
    1)
      curl -sSL https://github.com/warp-go/warp-go/releases/latest/download/warp-go-linux-amd64.tar.gz | tar -xz
      mv warp-go /usr/local/bin/
      chmod +x /usr/local/bin/warp-go
      echo "✅ warp-go 安装完成"
      ;;
    2)
      nohup warp-go > /dev/null 2>&1 &
      echo "✅ WARP 已启动"
      ;;
    3)
      pkill warp-go && echo "🚫 WARP 已停止"
      ;;
    4)
      pgrep warp-go >/dev/null && echo "✅ WARP 正在运行" || echo "🚫 WARP 未运行"
      ;;
    0) ;;
    *) echo "❌ 无效选择" ;;
  esac
}

  echo -e "\n按回车键返回主菜单..."
  read
done
