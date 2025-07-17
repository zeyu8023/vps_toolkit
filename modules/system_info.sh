# Version: 2.3.2
#!/bin/bash
echo "✅ 已加载 system_info.sh"

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

log() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [system_info] $message" >> "$LOG_FILE"
}

system_info() {
  while true; do
    clear
    echo "🖥️ 系统信息与搜索助手"
    echo "────────────────────────────────────────────"
    echo " 1. 查看系统信息概览"
    echo " 2. 搜索程序或服务状态"
    echo " 0. 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入操作编号: " sys_choice

    case "$sys_choice" in
      1)
        show_system_info
        log "查看系统信息概览"
        read -p "🔙 回车返回菜单..." ;;
      2)
        search_program
        read -p "🔙 回车返回菜单..." ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
    esac
  done
}

show_system_info() {
  # 检查依赖
  for cmd in curl jq; do
    if ! command -v $cmd &>/dev/null; then
      echo "⚠️ 缺少依赖：$cmd"
      read -p "是否自动安装 $cmd？(y/n): " confirm
      if [[ "$confirm" == "y" ]]; then
        if command -v apt &>/dev/null; then
          apt update && apt install -y $cmd
        elif command -v yum &>/dev/null; then
          yum install -y $cmd
        else
          echo "❌ 未知包管理器，无法自动安装 $cmd"
          return
        fi
      else
        echo "❌ 已取消安装，无法显示完整信息"
        return
      fi
    fi
  done

  echo -e "\n🖥️ 系统信息概览："
  echo "──────────────────────────────────────────────"
  echo "主机名：$(hostname)"
  echo "操作系统：$(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
  echo "内核版本：$(uname -r)"
  echo "系统运行时间：$(uptime -p)"
  echo "当前时间：$(date '+%Y-%m-%d %H:%M:%S')"
  echo "CPU型号：$(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
  echo "CPU核心数：$(nproc)"
  echo "CPU负载：$(uptime | awk -F'load average:' '{print $2}' | xargs)"
  echo "总进程数：$(ps aux | wc -l)"
  echo "内存总量：$(free -h | awk '/Mem:/ {print $2}')"
  echo "内存已用：$(free -h | awk '/Mem:/ {print $3}')"
  echo "Swap总量：$(free -h | awk '/Swap:/ {print $2}')"
  echo "Swap已用：$(free -h | awk '/Swap:/ {print $3}')"
  echo "磁盘使用：$(df -h / | awk 'NR==2 {print $3 " 已用 / " $2 " 总 (" $5 " 使用率)"}')"
  echo "──────────────────────────────────────────────"
  echo "🌐 网络信息："
  echo "本地 IP：$(hostname -I | awk '{print $1}')"
  echo "默认网关：$(ip route | grep default | awk '{print $3}')"
  echo "DNS 服务器：$(grep nameserver /etc/resolv.conf | awk '{print $2}' | paste -sd ',')"
  echo "公网 IP：$(curl -s ifconfig.me)"
  echo "公网 IP 来源：$(curl -s ipinfo.io | jq -r '.ip + " | " + .org + " | " + .city' 2>/dev/null)"
  echo "──────────────────────────────────────────────"
  echo "BBR状态：$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')"
  echo "BBR是否启用：$(lsmod | grep -q bbr && echo "✅ 已启用" || echo "❌ 未启用")"
  echo "──────────────────────────────────────────────"
}

search_program() {
  read -p "请输入程序或服务名关键词: " keyword
  log "搜索程序或服务状态：关键词 [$keyword]"

  which "$keyword" 2>/dev/null && echo "✅ 可执行文件路径：$(which "$keyword")"
  systemctl status "$keyword" 2>/dev/null | head -n 10 && echo "✅ systemd 服务状态已显示"
  apt list --installed 2>/dev/null | grep "$keyword" && echo "✅ 已安装的软件包匹配"
}
