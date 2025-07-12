# Version: 2.3.0
#!/bin/bash
echo "✅ 已加载 test_tools.sh"
# 模块：常用测试脚本功能

test_tools() {
  while true; do
    echo -e "\n🧪 常用测试脚本功能"
    echo "────────────────────────────────────────────"
    echo " 1) IP质量测试"
    echo " 2) 网络质量检测"
    echo " 3) NodeQuality完整测试"
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
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
