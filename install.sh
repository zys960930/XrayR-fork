#!/bin/bash
# XrayR Install Script (Community Fork)
# 原始仓库 XrayR-project/XrayR-release 已删除
# 二进制来自 XrayR-project/XrayR/releases (源码仓库仍可用)
# Fork 维护: https://github.com/zys960930/XrayR-fork

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

FORK_REPO="zys960930/XrayR-fork"
FORK_RAW="https://raw.githubusercontent.com/${FORK_REPO}/master"
RELEASE_BASE="https://github.com/XrayR-project/XrayR/releases/latest/download"
INSTALL_DIR="/usr/local/XrayR"
CONFIG_DIR="/etc/XrayR"
SERVICE_FILE="/etc/systemd/system/XrayR.service"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

detect_arch() {
    # 检测系统架构
    arch=$(uname -m)
    os=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "$arch" in
        x86_64|amd64) arch="64" ;;
        i386|i686) arch="32" ;;
        aarch64|arm64) arch="arm64-v8a" ;;
        armv7|armv7l) arch="arm32-v7a" ;;
        *)
            echo -e "${red}不支持的架构: $arch${plain}"
            exit 1
            ;;
    esac

    case "$os" in
        linux) os="linux" ;;
        freebsd) os="freebsd" ;;
        darwin)
            echo -e "${red}不支持 macOS，请使用 Linux 系统${plain}"
            exit 1
            ;;
        *)
            echo -e "${red}不支持的系统: $os${plain}"
            exit 1
            ;;
    esac

    BINARY_NAME="XrayR-${os}-${arch}.zip"
    echo "$BINARY_NAME"
}

install() {
    echo -e "${green}===== 开始安装 XrayR =====${plain}"

    # 创建目录
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"

    # 1. 下载配置文件
    echo -e "${yellow}[1/4] 下载配置文件...${plain}"
    for f in config.yml custom_inbound.json custom_outbound.json dns.json route.json rulelist; do
        curl -sL "${FORK_RAW}/config/${f}" -o "${CONFIG_DIR}/${f}" && echo "  ✓ ${f}" || echo "  ✗ ${f}"
    done

    # 2. 下载 systemd 服务文件
    echo -e "${yellow}[2/4] 下载 systemd 服务文件...${plain}"
    curl -sL "${FORK_RAW}/system/XrayR.service" -o "$SERVICE_FILE" && echo "  ✓ XrayR.service"

    # 3. 下载管理脚本
    echo -e "${yellow}[3/4] 下载管理脚本...${plain}"
    curl -sL "${FORK_RAW}/scripts/xrayr-manager.sh" -o /usr/bin/XrayR && chmod +x /usr/bin/XrayR
    ln -sf /usr/bin/XrayR /usr/bin/xrayr

    # 4. 下载 XrayR 二进制
    echo -e "${yellow}[4/4] 下载 XrayR 二进制文件...${plain}"
    BINARY_NAME=$(detect_arch)
    echo "  检测到架构: $BINARY_NAME"

    DOWNLOAD_URL="${RELEASE_BASE}/${BINARY_NAME}"
    TMP_ZIP="/tmp/${BINARY_NAME}"

    echo "  下载: ${DOWNLOAD_URL}"
    curl -L -# "$DOWNLOAD_URL" -o "$TMP_ZIP"

    if [[ $? -ne 0 || ! -f "$TMP_ZIP" ]]; then
        echo ""
        echo -e "${red}下载失败，请手动下载:${plain}"
        echo "  $DOWNLOAD_URL"
        echo "  解压后将 XrayR 放到 $INSTALL_DIR/"
        echo "  然后执行: chmod +x $INSTALL_DIR/XrayR && systemctl start XrayR"
    else
        cd /tmp
        unzip -o "$TMP_ZIP" -d /tmp/xrayr-extract/ >/dev/null 2>&1
        find /tmp/xrayr-extract/ -name "XrayR" -type f -exec mv {} "$INSTALL_DIR/XrayR" \;
        chmod +x "$INSTALL_DIR/XrayR"
        rm -rf /tmp/xrayr-extract "$TMP_ZIP"
        echo "  ✓ XrayR 二进制安装完成"
    fi

    # 重载 systemd
    systemctl daemon-reload

    echo ""
    echo -e "${green}===== 安装完成 =====${plain}"
    echo ""
    echo -e "配置文件: ${yellow}${CONFIG_DIR}/config.yml${plain}"
    echo -e "启动服务: ${yellow}XrayR start${plain}"
    echo -e "查看状态: ${yellow}XrayR status${plain}"
    echo ""
    echo -e "${green}请先编辑配置文件，修改你的面板信息:${plain}"
    echo -e "  vi ${CONFIG_DIR}/config.yml"
}

update_shell() {
    echo -e "${green}更新管理脚本...${plain}"
    curl -sL "${FORK_RAW}/scripts/xrayr-manager.sh" -o /usr/bin/XrayR && chmod +x /usr/bin/XrayR
    echo -e "${green}管理脚本更新完成！${plain}"
}

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

case "$1" in
    install) install ;;
    uninstall) uninstall ;;
    update_shell) update_shell ;;
    *)
        echo "XrayR 安装脚本 (社区 Fork)"
        echo "用法:"
        echo "  bash install.sh install      - 安装 XrayR"
        echo "  bash install.sh uninstall    - 卸载 XrayR"
        echo "  bash install.sh update_shell - 更新管理脚本"
        ;;
esac
