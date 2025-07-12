# Version: 2.3.0
#!/bin/bash
echo "✅ 已加载 network_tools.sh"
# 模块：网络设置中心

network_tools() {
  network_settings_menu
}

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

  ipv4=$(curl -4 -s https://ifconfig.co)
  if [[ "$ipv4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "公网 IPv4：$ipv4"
  else
    echo "公网 IPv4：未检测到 IPv4 地址"
  fi

  ipv6=$(curl -6 -s https://ifconfig.co)
  if [[ "$ipv6" =~ : ]]; then
    echo "公网 IPv6：$ipv6"
  else
    echo "公网 IPv6：未检测到 IPv6 地址"
  fi

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
