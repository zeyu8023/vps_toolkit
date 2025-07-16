# Version: 2.3.9
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
  read -p "🔑 输入新的 GitHub Token（classic，repo 权限）: " new_token
  [[ -n "$new_token" ]] && save_token "$new_token"
}

clear_token() {
  rm -f "$TOKEN_FILE"
  echo "🧹 已清除保存的 Token"
}

submit_to_public_repo() {
  echo -e "\n🚀 提交脚本收藏夹到公共仓库（vps-toolkit-scripts）"
  read -p "👤 你的 GitHub 用户名: " username
  token=$(get_saved_token)

  if [[ -z "$token" ]]; then
    read -p "🔑 输入你的 GitHub Token（classic，repo 权限）: " token
    [[ -z "$token" ]] && echo "❌ Token 不能为空" && return
    save_token "$token"
  else
    echo "🔐 已使用保存的 Token"
  fi

  if [[ ! -f "$SCRIPT_LIST" ]]; then
    echo "❌ 脚本列表不存在：$SCRIPT_LIST"
    return
  fi

  TMP_DIR=$(mktemp -d)
  REPO_URL="https://github.com/zeyu8023/vps-toolkit-scripts.git"
  cd "$TMP_DIR" || return
  git init
  git config user.name "$username"
  git config user.email "$username@users.noreply.github.com"
  git remote add origin "$REPO_URL"

  echo "📥 正在拉取远程仓库..."
  git pull origin master &>/dev/null

  mkdir -p "$username"
  cp "$SCRIPT_LIST" "$username/test_scripts.list"

  git add .
  git commit -m "提交脚本收藏夹：$username"
  git push "https://$username:$token@github.com/zeyu8023/vps-toolkit-scripts.git" master

  echo "✅ 已提交到公共仓库：https://github.com/zeyu8023/vps-toolkit-scripts/tree/master/$username"
  log "提交脚本收藏夹到公共仓库：$username"
}

restore_from_public_repo() {
  echo -e "\n🔄 从公共仓库恢复脚本收藏夹"
  read -p "👤 请输入你的 GitHub 用户名: " username

  url="https://raw.githubusercontent.com/zeyu8023/vps-toolkit-scripts/master/$username/test_scripts.list"
  echo "🌐 正在拉取：$url"

  content=$(curl -s "$url")
  if [[ -n "$content" && "$content" == *"|"* ]]; then
    echo "$content" > "$SCRIPT_LIST"
    echo "✅ 已恢复脚本收藏夹到：$SCRIPT_LIST"
    log "从公共仓库恢复脚本：$username"
  else
    echo "❌ 恢复失败，可能用户名错误或文件不存在"
  fi
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
echo " 0) 返回上一级"

read -p "👉 请输入要管理的脚本编号（输入 0 返回）: " num
[[ "$num" == "0" ]] && return

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
    echo " 7) 更新 GitHub Token 🔑"
    echo " 8) 清除保存的 Token 🧹"
    echo " 9) 提交脚本到公共仓库 🚀"
    echo "10) 从公共仓库恢复脚本 🔄"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    echo "🙏 鸣谢脚本作者：@xykt"
    echo "📎 GitHub主页：https://github.com/xykt"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1) bash <(curl -sL Check.Place) -I; log "运行 IP质量测试脚本" ;;
      2) bash <(curl -sL Check.Place) -N; log "运行 网络质量检测脚本" ;;
      3) bash <(curl -sL https://run.NodeQuality.com); log "运行 NodeQuality验证测试脚本" ;;
      4) add_custom_script ;;
      5) run_custom_scripts ;;
      6) manage_custom_scripts ;;
      7) update_token ;;
      8) clear_token ;;
      9) submit_to_public_repo ;;
     10) restore_from_public_repo ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
