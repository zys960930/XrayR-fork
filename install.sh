#!/bin/bash

# XrayR Install Script (Community Fork)
# 原始仓库 XrayR-project/XrayR-release 已删除
# 此 Fork 由 zys960930 维护

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

GITHUB_REPO="zys960930/XrayR-fork"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/master"
INSTALL_DIR="/usr/local/XrayR"
CONFIG_DIR="/etc/XrayR"
SERVICE_FILE="/etc/systemd/system/XrayR.service"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}未检测到系统版本！${plain}\n" && exit 1
fi

# 1. Install XrayR
install() {
    echo -e "${green}开始安装 XrayR...${plain}"

    # 创建目录
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"

    # 下载配置文件
    echo -e "${yellow}下载配置文件中...${plain}"
    for f in config.yml custom_inbound.json custom_outbound.json dns.json route.json rulelist; do
        curl -sL "${RAW_URL}/config/${f}" -o "${CONFIG_DIR}/${f}" && echo "  ✓ ${f}" || echo "  ✗ ${f} 下载失败"
    done

    # 下载 systemd 服务文件
    echo -e "${yellow}下载服务文件中...${plain}"
    curl -sL "${RAW_URL}/system/XrayR.service" -o "$SERVICE_FILE" && echo "  ✓ XrayR.service"

    # 下载管理脚本
    echo -e "${yellow}下载管理脚本中...${plain}"
    curl -sL "${RAW_URL}/scripts/xrayr-manager.sh" -o /usr/bin/XrayR && chmod +x /usr/bin/XrayR
    ln -sf /usr/bin/XrayR /usr/bin/xrayr

    # 提示用户下载 XrayR 二进制文件
    echo ""
    echo -e "${yellow}========================================${plain}"
    echo -e "${yellow}XrayR 二进制文件需要单独下载：${plain}"
    echo -e "${green}  1. 前往 Releases 页面下载最新版本${plain}"
    echo -e "${green}     https://github.com/XrayR-project/XrayR/releases${plain}"
    echo -e "${green}  2. 上传到服务器并执行：${plain}"
    echo -e "${green}     mv XrayR-linux-64.zip /tmp/ && cd /tmp && unzip XrayR-linux-64.zip${plain}"
    echo -e "${green}     mv XrayR ${INSTALL_DIR}/XrayR && chmod +x ${INSTALL_DIR}/XrayR${plain}"
    echo -e "${green}  3. 编辑配置文件：${plain}"
    echo -e "${green}     vi ${CONFIG_DIR}/config.yml${plain}"
    echo -e "${yellow}========================================${plain}"

    # 重载 systemd
    systemctl daemon-reload
    echo ""
    echo -e "${green}安装完成！${plain}"
    echo -e "请先下载 XrayR 二进制文件到 ${INSTALL_DIR}/ 目录"
    echo -e "然后运行 ${green}XrayR start${plain} 启动服务"
}

# 2. Update XrayR manager script
update_shell() {
    echo -e "${green}更新管理脚本...${plain}"
    curl -sL "${RAW_URL}/scripts/xrayr-manager.sh" -o /usr/bin/XrayR && chmod +x /usr/bin/XrayR
    echo -e "${green}管理脚本更新完成！${plain}"
}

# 3. Uninstall
uninstall() {
    echo -e "${red}卸载 XrayR...${plain}"
    systemctl stop XrayR 2>/dev/null
    systemctl disable XrayR 2>/dev/null
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload
    rm -rf "$CONFIG_DIR"
    rm -rf "$INSTALL_DIR"
    rm -f /usr/bin/XrayR /usr/bin/xrayr
    echo -e "${green}卸载完成！${plain}"
}

# Menu
case "$1" in
    install)
        install
        ;;
    update_shell)
        update_shell
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "用法:"
        echo "  bash install.sh install      - 安装 XrayR"
        echo "  bash install.sh uninstall    - 卸载 XrayR"
        echo "  bash install.sh update_shell - 更新管理脚本"
        ;;
esac
