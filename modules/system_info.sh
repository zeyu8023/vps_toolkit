# Version: 2.3.1
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
  echo -e "\n🖥️ 系统信息概览："
  echo "主机名：$(hostname)"
  echo "操作系统：$(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
  echo "内核版本：$(uname -r)"
  echo "CPU：$(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
  echo "内存总量：$(free -h | awk '/Mem:/ {print $2}')"
  echo "公网 IP：$(curl -s ifconfig.me)"
}

search_program() {
  read -p "请输入程序或服务名关键词: " keyword
  log "搜索程序或服务状态：关键词 [$keyword]"

  which "$keyword" 2>/dev/null && echo "✅ 可执行文件路径：$(which "$keyword")"
  systemctl status "$keyword" 2>/dev/null | head -n 10 && echo "✅ systemd 服务状态已显示"
  apt list --installed 2>/dev/null | grep "$keyword" && echo "✅ 已安装的软件包匹配"
}
