#!/bin/bash
# 模块：系统信息与搜索助手

search_program() {
  read -p "请输入程序或服务名关键词: " keyword
  which "$keyword" 2>/dev/null && echo "✅ 可执行文件路径：$(which "$keyword")"
  systemctl status "$keyword" 2>/dev/null | head -n 10 && echo "✅ systemd 服务状态已显示"
  apt list --installed 2>/dev/null | grep "$keyword" && echo "✅ 已安装的软件包匹配"
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
