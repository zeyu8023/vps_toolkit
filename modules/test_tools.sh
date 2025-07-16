# Version: 2.3.6
#!/bin/bash
echo "✅ 已加载 test_tools.sh"
# 模块：常用测试脚本功能 🧪

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"
SCRIPT_LIST="/opt/vps_toolkit/config/test_scripts.list"
TOKEN_FILE="/opt/vps_toolkit/config/github_token.txt"

mkdir -p /opt/vps_toolkit/config
touch "$SCRIPT_LIST"

log() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [test_tools] $message" >> "$LOG_FILE"
}

get_saved_token() {
  [[ -f "$TOKEN_FILE" ]] && cat "$TOKEN_FILE"
}

save_token() {
  local token="$1"
  echo "$token" > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
  echo "✅ Token 已保存，下次将自动使用"
}

update_token() {
  read -p "🔑 输入新的 GitHub Token（classic，gist 权限）: " new_token
  [[ -n "$new_token" ]] && save_token "$new_token"
}

clear_token() {
  rm -f "$TOKEN_FILE"
  echo "🧹 已清除保存的 Token"
}

add_custom_script() {
  echo -e "\n📝 添加自定义测试脚本"
  read -p "📛 输入脚本名称: " name
  read -p "🔗 输入执行命令（如 bash <(curl -sL ...)）: " cmd

  if [[ -n "$name" && -n "$cmd" ]]; then
    echo "$name|$cmd" >> "$SCRIPT_LIST"
    echo "✅ 已添加脚本：$name"
    log "添加自定义测试脚本：$name"
  else
    echo "❌ 名称或命令不能为空"
  fi
}

run_custom_scripts() {
  echo -e "\n📂 脚本收藏夹列表："
  mapfile -t lines < "$SCRIPT_LIST"

  if [[ ${#lines[@]} -eq 0 ]]; then
    echo "⚠️ 当前没有收藏的脚本"
    return
  fi

  for i in "${!lines[@]}"; do
    [[ "${lines[$i]}" != *"|"* ]] && continue
    name="${lines[$i]%%|*}"
    echo " $((i+1))) $name"
  done

  read -p "👉 请输入要运行的脚本编号: " num
  index=$((num-1))
  cmd="${lines[$index]#*|}"

  if [[ -n "$cmd" ]]; then
    echo "🚀 正在运行：${lines[$index]%%|*}"
    eval "$cmd"
    log "运行收藏夹脚本：${lines[$index]%%|*}"
  else
    echo "❌ 无效编号或命令为空"
  fi
}

manage_custom_scripts() {
  echo -e "\n🛠️ 管理脚本收藏夹"
  mapfile -t raw_lines < "$SCRIPT_LIST"

  valid_lines=()
  invalid_lines=()

  for line in "${raw_lines[@]}"; do
    if [[ "$line" == *"|"* ]]; then
      valid_lines+=("$line")
    else
      invalid_lines+=("$line")
    fi
  done

  if [[ ${#valid_lines[@]} -eq 0 ]]; then
    echo "⚠️ 当前没有有效格式的脚本收藏记录"
    [[ ${#invalid_lines[@]} -gt 0 ]] && echo "❌ 以下行格式错误，请手动修复：" && printf " - %s\n" "${invalid_lines[@]}"
    return
  fi

  echo "📂 有效脚本列表："
  for i in "${!valid_lines[@]}"; do
    name="${valid_lines[$i]%%|*}"
    echo " $((i+1))) $name"
  done

  read -p "👉 请输入要管理的脚本编号: " num
  index=$((num-1))
  [[ -z "${valid_lines[$index]}" ]] && echo "❌ 无效编号" && return

  name="${valid_lines[$index]%%|*}"
  cmd="${valid_lines[$index]#*|}"

  echo -e "\n📝 当前脚本：$name"
  echo "🔗 当前命令：$cmd"
  echo "────────────────────────────────────────────"
  echo " 1) 修改名称"
  echo " 2) 修改命令"
  echo " 3) 删除脚本"
  echo " 0) 返回"
  echo "────────────────────────────────────────────"
  read -p "👉 请输入操作编号: " action

  case "$action" in
    1)
      read -p "✏️ 输入新名称: " new_name
      [[ -n "$new_name" ]] && valid_lines[$index]="$new_name|$cmd" && echo "✅ 名称已更新为：$new_name"
      ;;
    2)
      read -p "🔧 输入新命令: " new_cmd
      [[ -n "$new_cmd" ]] && valid_lines[$index]="$name|$new_cmd" && echo "✅ 命令已更新"
      ;;
    3)
      unset 'valid_lines[$index]'
      echo "✅ 已删除脚本：$name"
      ;;
    0) return ;;
    *) echo "❌ 无效操作编号" ;;
  esac

  printf "%s\n" "${valid_lines[@]}" > "$SCRIPT_LIST"
  log "管理脚本：$name（操作编号 $action）"
}

upload_to_gist() {
  echo -e "\n☁️ 上传脚本收藏夹到 GitHub Gist"
  token=$(get_saved_token)

  if [[ -z "$token" ]]; then
    read -p "🔑 输入你的 GitHub Token（classic，gist 权限）: " token
    [[ -z "$token" ]] && echo "❌ Token 不能为空" && return
    save_token "$token"
  else
    echo "🔐 已使用保存的 Token"
  fi

  content=$(<"$SCRIPT_LIST")
  if [[ -z "$content" ]]; then
    echo "⚠️ 脚本收藏夹为空，无法上传"
    return
  fi

  payload=$(jq -n --arg content "$content" '{
    description: "VPS Toolkit Script Backup",
    public: false,
    files: {
      "test_scripts.list": { "content": $content }
    }
  }')

  response=$(curl -s -X POST https://api.github.com/gists \
    -H "Authorization: token '"$token"'" \
    -H "Content-Type: application/json" \
    -d "$payload")

  url=$(echo "$response" | jq -r '.html_url')
  if [[ "$url" != "null" ]]; then
    echo "✅ 已上传到 Gist：$url"
    log "上传脚本收藏到 Gist：$url"
  else
    echo "❌ 上传失败，响应内容如下："
    echo "$response"
  fi
}

restore_from_gist() {
  echo -e "\n🔄 从 GitHub Gist 恢复脚本收藏夹"
  read -p "🔗 输入 Gist ID 或完整 URL: " gist_input
  [[ -z "$gist_input" ]] && echo "❌ 输入不能为空" && return

  gist_id=$(echo "$gist_input" | sed 's|.*gist.github.com/||;s|/.*||')
  raw_url="https://gist.githubusercontent.com/$gist_id/raw"

  content=$(curl -s "$raw_url")
  if [[ -n "$content" ]]; then
    echo "$content" > "$SCRIPT_LIST"
    echo "✅ 已恢复脚本收藏夹"
    log "从 Gist 恢复脚本收藏夹：$gist_id"
  else
    echo "❌ 恢复失败，请检查 Gist ID 或网络"
  fi
}

test_tools() {
  while true; do
    echo -e "\n🧪 常用测试脚本功能"
    echo "────────────────────────────────────────────"
    echo " 1) IP质量测试"
    echo " 2) 网络质量检测"
    echo " 3) NodeQuality完整测试"
    echo " 4) 添加自定义测试脚本"
    echo " 5) 运行收藏夹脚本"
    echo " 6) 管理脚本收藏夹"
    echo " 7) 上传脚本收藏夹到 GitHub Gist ☁️"
    echo " 8) 从 Gist 恢复脚本收藏夹 🔄"
    echo " 9) 更新 GitHub Token 🔑"
    echo "10) 清除保存的 Token 🧹"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    echo "🙏 鸣谢脚本作者：@xykt"
    echo "📎 GitHub主页：https://github.com/xykt"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        echo "🚀 正在运行 IP质量测试..."
        bash <(curl -sL Check.Place) -I
        log "运行 IP质量测试脚本"
        ;;
      2)
        echo "🚀 正在运行 网络质量检测..."
        bash <(curl -sL Check.Place) -N
        log "运行 网络质量检测脚本"
        ;;
      3)
        echo "🚀 正在运行 NodeQuality验证测试..."
        bash <(curl -sL https://run.NodeQuality.com)
        log "运行 NodeQuality验证测试脚本"
        ;;
      4) add_custom_script ;;
      5) run_custom_scripts ;;
      6) manage_custom_scripts ;;
      7) upload_to_gist ;;
      8) restore_from_gist ;;
      9) update_token ;;
     10) clear_token ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
