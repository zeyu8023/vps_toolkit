# Version: 2.3.1
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
        echo "📥 正在申请证书（使用 standalone 模式）..."
        sudo certbot certonly --standalone -d "$domain" \
          && echo "✅ 证书申请成功" \
          || echo "❌ 证书申请失败"
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
