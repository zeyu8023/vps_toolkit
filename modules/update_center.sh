# Version: 2.3.0
#!/bin/bash
echo "✅ 已加载 update_center.sh"
# 模块：模块更新中心

REPO_BASE="https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/modules"
LOCAL_DIR="/opt/vps_toolkit/modules"

update_center() {
  while true; do
    echo -e "\n🔄 模块更新中心"
    echo "────────────────────────────────────────────"
    echo " 1) 查看当前模块版本"
    echo " 2) 更新所有模块"
    echo " 3) 更新指定模块"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        echo -e "\n📋 当前模块版本信息（需模块顶部包含 # Version:）："
        for file in "$LOCAL_DIR"/*.sh; do
          name=$(basename "$file")
          version=$(grep "^# Version:" "$file" | cut -d: -f2 | xargs)
          [[ -z "$version" ]] && version="未标注"
          printf "%-25s 版本: %s\n" "$name" "$version"
        done
        ;;
      2)
        echo -e "\n📥 正在更新所有模块..."
        for file in "$LOCAL_DIR"/*.sh; do
          name=$(basename "$file")
          curl -fsSL "$REPO_BASE/$name" -o "$file" \
            && echo "✅ 已更新：$name" \
            || echo "❌ 更新失败：$name"
        done
        ;;
      3)
        echo -e "\n📦 可更新模块列表："
        ls "$LOCAL_DIR"/*.sh | sed 's|.*/||' | nl
        read -p "📥 输入模块编号进行更新: " num
        selected=$(ls "$LOCAL_DIR"/*.sh | sed 's|.*/||' | sed -n "${num}p")
        if [[ -n "$selected" ]]; then
          curl -fsSL "$REPO_BASE/$selected" -o "$LOCAL_DIR/$selected" \
            && echo "✅ 已更新：$selected" \
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
