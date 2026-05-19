#!/bin/bash
# XrayR Install Script (Fork)
# Original repo has been deleted, this is a community-maintained fork
set -e

# Detect OS
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
    echo "Unsupported OS" && exit 1
fi

INSTALL_DIR="/usr/local/XrayR"
CONFIG_DIR="/etc/XrayR"
SERVICE_FILE="/etc/systemd/system/XrayR.service"

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

echo "Please download the latest XrayR binary from the Releases page."
echo "Then run: chmod +x XrayR && mv XrayR $INSTALL_DIR/XrayR"
echo ""
echo "Sample config files are in the config/ directory."
echo "Edit $CONFIG_DIR/config.yml with your settings."
