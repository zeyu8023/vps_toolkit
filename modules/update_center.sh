# Version: 2.3.1
#!/bin/bash
echo "✅ 已加载 update_center.sh"
# 模块：模块更新中心

REPO_BASE="https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/modules"
LOCAL_DIR="/opt/vps_toolkit/modules"
LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

log() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [update_center] $message" >> "$LOG_FILE"
}

get_version() {
  local file="$1"
  grep "^# Version:" "$file" 2>/dev/null | cut -d: -f2 | xargs
}

get_remote_version() {
  local name="$1"
  curl -fsSL "$REPO_BASE/$name" 2>/dev/null | grep "^# Version:" | cut -d: -f2 | xargs
}

update_center() {
  while true; do
    echo -e "\n🔄 模块更新中心"
    echo "────────────────────────────────────────────"
    echo " 1) 查看当前模块版本"
    echo " 2) 检查远程更新（版本对比）"
    echo " 3) 更新所有模块"
    echo " 4) 更新指定模块"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        echo -e "\n📋 当前模块版本信息："
        for file in "$LOCAL_DIR"/*.sh; do
          name=$(basename "$file")
          version=$(get_version "$file")
          [[ -z "$version" ]] && version="未标注"
          printf "%-25s 版本: %s\n" "$name" "$version"
        done
        ;;
      2)
        echo -e "\n🔍 正在检查远程更新..."
        updates=0
        for file in "$LOCAL_DIR"/*.sh; do
          name=$(basename "$file")
          local_ver=$(get_version "$file")
          remote_ver=$(get_remote_version "$name")
          [[ -z "$local_ver" ]] && local_ver="未标注"
          [[ -z "$remote_ver" ]] && remote_ver="无法获取"
          if [[ "$local_ver" != "$remote_ver" ]]; then
            printf "📦 %-20s 本地: %-10s 远程: %-10s  👉 可更新\n" "$name" "$local_ver" "$remote_ver"
            ((updates++))
          else
            printf "✅ %-20s 已是最新版本 (%s)\n" "$name" "$local_ver"
          fi
        done

        if (( updates > 0 )); then
          read -p "📥 检测到 $updates 个可更新模块，是否立即更新所有？(y/n): " confirm
          if [[ "$confirm" == "y" ]]; then
            echo -e "\n📥 正在更新所有模块..."
            for file in "$LOCAL_DIR"/*.sh; do
              name=$(basename "$file")
              curl -fsSL "$REPO_BASE/$name" -o "$file" \
                && echo "✅ 已更新：$name" \
                && log "✅ 已更新模块：$name" \
                && source "$file" \
                || echo "❌ 更新失败：$name"
            done
          else
            echo "🚫 已取消自动更新"
          fi
        else
          echo "✅ 所有模块均为最新版本"
        fi
        ;;
      3)
        echo -e "\n📥 正在更新所有模块..."
        for file in "$LOCAL_DIR"/*.sh; do
          name=$(basename "$file")
          curl -fsSL "$REPO_BASE/$name" -o "$file" \
            && echo "✅ 已更新：$name" \
            && log "✅ 已更新模块：$name" \
            && source "$file" \
            || echo "❌ 更新失败：$name"
        done
        ;;
      4)
        echo -e "\n📦 可更新模块列表："
        ls "$LOCAL_DIR"/*.sh | sed 's|.*/||' | nl
        read -p "📥 输入模块编号进行更新: " num
        selected=$(ls "$LOCAL_DIR"/*.sh | sed 's|.*/||' | sed -n "${num}p")
        if [[ -n "$selected" ]]; then
          curl -fsSL "$REPO_BASE/$selected" -o "$LOCAL_DIR/$selected" \
            && echo "✅ 已更新：$selected" \
            && log "✅ 已更新模块：$selected" \
            && source "$LOCAL_DIR/$selected" \
            || echo "❌ 更新失败：$selected"
        else
          echo "❌ 无效编号"
        fi
        ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
