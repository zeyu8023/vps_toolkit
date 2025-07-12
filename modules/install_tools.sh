#!/bin/bash
# ✅ 已加载 install_tools.sh
# 模块：环境安装器

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
  to_install=""
  prompt_and_install "Docker 环境" map
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

  local pkg_mgr=""
  if command -v apt >/dev/null; then
    pkg_mgr="apt"
  elif command -v yum >/dev/null; then
    pkg_mgr="yum"
  else
    echo "❌ 不支持的包管理器"
    return
  fi

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

# ✅ 添加桥接函数供主菜单调用
install_tools() {
  install_environment_menu
}
