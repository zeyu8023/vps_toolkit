# Version: 2.3.2
#!/bin/bash
echo "✅ 已加载 ssl_manager.sh"
# 模块：SSL 证书管理中心

# ✅ 通用依赖检测函数
ensure_command() {
  local cmd="$1"
  local pkg="$2"
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ 缺少命令：$cmd（建议安装 $pkg）"
    read -p "📥 是否安装 $pkg？(y/n): " confirm
    [[ "$confirm" == "y" ]] && sudo apt update && sudo apt install "$pkg" -y
  fi
}

ssl_manager() {
  ensure_command certbot certbot
  ensure_command openssl openssl

  while true; do
    echo -e "\n🔐 SSL 证书管理中心"
    echo "────────────────────────────────────────────"
    echo " 1) 申请新证书"
    echo " 2) 续签所有证书"
    echo " 3) 吊销证书"
    echo " 4) 查看证书信息"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        read -p "🌐 输入要申请证书的域名: " domain

        # ✅ 检查端口 80 是否被占用
        echo "🔍 正在检查端口 80 是否被占用..."
        port_check=$(sudo lsof -i :80 | grep LISTEN)
        killed_service=""

        if [[ -n "$port_check" ]]; then
          echo "⚠️ 端口 80 已被占用，可能影响证书申请"
          echo "$port_check"
          pid=$(echo "$port_check" | awk '{print $2}' | head -n 1)
          exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null)
          service_name=""

          # ✅ 尝试识别服务名
          if [[ "$exe" == *nginx* ]]; then
            service_name="nginx"
          elif [[ "$exe" == *apache2* ]]; then
            service_name="apache2"
          fi

          read -p "🛑 是否终止占用端口的进程 PID: $pid？(y/n): " confirm
          if [[ "$confirm" == "y" ]]; then
            sudo kill -9 "$pid" && echo "✅ 已终止进程 PID: $pid"
            killed_service="$service_name"
          else
            echo "❌ 已取消申请证书"
            continue
          fi
        else
          echo "✅ 端口 80 未被占用"
        fi

        # ✅ 执行证书申请（无邮箱）
        echo "📥 正在申请证书（使用 standalone 模式，无邮箱）..."
        if sudo certbot certonly --standalone \
          --register-unsafely-without-email \
          --agree-tos \
          -d "$domain"; then
          echo "✅ 证书申请成功"

          # ✅ 提示是否恢复服务
          if [[ -n "$killed_service" ]]; then
            read -p "🔄 是否恢复被终止的服务 $killed_service？(y/n): " restart_confirm
            if [[ "$restart_confirm" == "y" ]]; then
              sudo systemctl restart "$killed_service" \
                && echo "✅ 已恢复服务：$killed_service" \
                || echo "❌ 恢复失败，请手动检查"
            fi
          fi
        else
          echo "❌ 证书申请失败"
        fi
        ;;
      2)
        echo "🔄 正在续签所有证书..."
        sudo certbot renew \
          && echo "✅ 续签完成" \
          || echo "❌ 续签失败"
        ;;
      3)
        read -p "🗑️ 输入要吊销的域名: " domain
        echo "⚠️ 正在吊销证书..."
        sudo certbot revoke --cert-path "/etc/letsencrypt/live/$domain/fullchain.pem" \
          && echo "✅ 已吊销证书" \
          || echo "❌ 吊销失败"
        ;;
      4)
        echo -e "\n📋 当前证书信息："
        for dir in /etc/letsencrypt/live/*; do
          domain=$(basename "$dir")
          expiry=$(openssl x509 -enddate -noout -in "$dir/fullchain.pem" 2>/dev/null | cut -d= -f2)
          [[ -n "$expiry" ]] && printf "🌐 %-25s 过期时间: %s\n" "$domain" "$expiry"
        done
        ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
