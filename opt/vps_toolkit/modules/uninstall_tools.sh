#!/bin/bash
# 模块：程序卸载工具

uninstall_program() {
  echo -e "\n📦 正在获取已安装程序列表..."
  if command -v apt >/dev/null; then
    mapfile -t pkgs < <(apt list --installed 2>/dev/null | grep -v "Listing...")
  elif command -v yum >/dev/null; then
    mapfile -t pkgs < <(yum list installed | awk 'NR>1 {print $1 "\t" $2}')
  else
    echo "❌ 不支持的包管理器"
    return
  fi

  echo -e "\n📋 已安装程序列表（前 50 个）："
  for i in "${!pkgs[@]}"; do
    [[ $i -ge 50 ]] && break
    if command -v apt >/dev/null; then
      name=$(echo "${pkgs[$i]}" | awk -F/ '{print $1}')
      desc=$(echo "${pkgs[$i]}" | awk '{print $2}')
      echo "$i) $name  —  $desc"
    else
      name=$(echo "${pkgs[$i]}" | awk '{print $1}')
      desc=$(echo "${pkgs[$i]}" | awk '{print $2}')
      echo "$i) $name  —  $desc"
    fi
  done

  echo -e "\n👉 输入程序编号进行卸载（直接回车退出）"
  read -p "编号: " index
  [[ -z "$index" ]] && echo "🚪 已退出卸载菜单" && return

  pkg=$(echo "${pkgs[$index]}" | awk -F/ '{print $1}' | awk '{print $1}')
  if [[ -z "$pkg" ]]; then
    echo "❌ 无效编号"
    return
  fi

  read -p "⚠️ 确认要卸载 $pkg？(y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    if command -v apt >/dev/null; then
      apt remove -y "$pkg"
    elif command -v yum >/dev/null; then
      yum remove -y "$pkg"
    fi
    echo "✅ 已卸载 $pkg"
    log "卸载程序：$pkg"
  else
    echo "🚫 已取消卸载"
  fi
}
