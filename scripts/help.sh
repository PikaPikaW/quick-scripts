#!/bin/bash
# ==============================================
# Quick Scripts 工具集合
# 版本：v1.0
# 作者：PikaPikaW
# ==============================================
 
 # 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色
BOLD='\033[1m'

# 工具函数
print_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "=============================================="
    echo "      Quick Scripts 工具集合"
    echo "=============================================="
    echo -e "${NC}"
}
 
print_info() {
    echo -e "${CYAN}[*]${NC} ${1}"
}
 
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} ${1}"
}
 
print_warning() {
    echo -e "${YELLOW}[!]${NC} ${1}"
}
 
print_divider() {
    echo -e "${BLUE}----------------------------------------------${NC}"
}
 
# 主函数
main() {
    print_header
    
    echo -e "${GREEN}${BOLD}欢迎使用 Quick Scripts 工具集合！${NC}"
    echo -e "${CYAN}本脚本将为您展示可用的工具脚本。${NC}"
    print_divider
    
    echo -e "${BOLD}${YELLOW}可用的脚本工具：${NC}"
    echo -e "${GREEN}1.${NC} ${BLUE}zsh${NC} - Zsh 终端环境一键安装配置"
    echo -e "${GREEN}2.${NC} ${BLUE}basic_tool${NC} - 基础工具安装脚本"
    echo -e "${GREEN}3.${NC} ${BLUE}dpdk${NC} - DPDK 安装配置脚本"
    print_divider
    
    echo -e "${BOLD}${YELLOW}使用方法：${NC}"
    echo -e "通过 curl 直接执行脚本："
    echo -e "${CYAN}sh -c 'curl -fsSL https://gitee.com/PikaPikaW/quick-scripts/raw/main/scripts/脚本名称/脚本文件 | bash'${NC}"
    print_divider
    
    echo -e "${BOLD}${YELLOW}示例：${NC}"
    echo -e "${CYAN}# 安装配置 Zsh${NC}"
    echo -e "${GREEN}sh -c 'curl -fsSL https://gitee.com/PikaPikaW/quick-scripts/raw/main/scripts/zsh/zsh_install.sh | bash'${NC}"
    echo -e ""
    echo -e "${CYAN}# 安装基础工具${NC}"
    echo -e "${GREEN}sh -c 'curl -fsSL https://gitee.com/PikaPikaW/quick-scripts/raw/main/scripts/basic_tool/basic_tool.sh | bash'${NC}"
    echo -e ""
    echo -e "${CYAN}# 安装配置 DPDK${NC}"
    echo -e "${GREEN}sh -c 'curl -fsSL https://gitee.com/PikaPikaW/quick-scripts/raw/main/scripts/dpdk/dpdk_install.sh | bash'${NC}"
    print_divider
    
    echo -e "${GREEN}${BOLD}脚本仓库：${NC}"
    echo -e "${BLUE}https://gitee.com/PikaPikaW/quick-scripts${NC}"
    echo -e "${BLUE}https://github.com/PikaPikaW/quick-scripts${NC}"
    print_divider
    
    echo -e "${YELLOW}${BOLD}提示：${NC}"
    echo -e "- 所有脚本均在 Linux 环境下测试通过"
    echo -e "- 部分脚本可能需要 root 权限"
    echo -e "- 使用前请确保网络连接正常"
    print_divider
    
    echo -e "${GREEN}${BOLD}感谢使用 Quick Scripts 工具集合！${NC}"
}
 
# 运行主函数
main