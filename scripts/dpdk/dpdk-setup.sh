#!/bin/bash

# DPDK 自动安装脚本
# 功能: 自动检测系统，安装依赖，编译安装 DPDK，并配置大页内存
# 适用系统: Ubuntu/Debian/CentOS/RHEL
# 使用方法: sudo ./install_dpdk.sh

set -e  # 遇到错误立即退出

# 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 请使用 root 或 sudo 运行此脚本!"
    exit 1
fi

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
elif [ -f /etc/redhat-release ]; then
    OS="centos"
    VER=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | cut -d '.' -f 1)
else
    echo "错误: 无法识别操作系统!"
    exit 1
fi

# 安装依赖
echo "==> 安装系统依赖..."
case $OS in
    ubuntu|debian)
        apt update
        apt install -y build-essential meson ninja-build python3-pyelftools \
            libnuma-dev pkg-config libssl-dev git kmod
        ;;
    centos|rhel)
        if [ "$OS" = "rhel" ] && [ "$VER" -eq 7 ]; then
            yum install -y epel-release
            yum install -y meson ninja-build python3-pyelftools \
                numactl-devel openssl-devel git kmod
        else
            dnf groupinstall -y "Development Tools"
            dnf install -y meson ninja-build python3-pyelftools \
                numactl-devel openssl-devel git kmod
        fi
        ;;
    *)
        echo "错误: 不支持的系统 $OS!"
        exit 1
        ;;
esac

# 克隆 DPDK 源码(默认使用最新稳定版)
DPDK_VERSION="23.11"
DPDK_DIR="/opt/dpdk"

echo "==> 下载 DPDK $DPDK_VERSION..."
if [ ! -d "$DPDK_DIR" ]; then
    git clone --branch "v$DPDK_VERSION" https://dpdk.org/git/dpdk "$DPDK_DIR"
else
    echo "警告: $DPDK_DIR 已存在，跳过克隆。"
fi

cd "$DPDK_DIR" || exit 1

# 编译 DPDK
echo "==> 编译 DPDK..."
meson setup build
cd build
ninja
ninja install

# 配置大页内存
echo "==> 配置大页内存(1024 x 2MB)..."
echo "vm.nr_hugepages=1024" >> /etc/sysctl.conf
sysctl -p

# 加载内核模块
echo "==> 加载 DPDK 内核模块..."
modprobe uio
if ! modprobe igb_uio; then
    echo "警告: igb_uio 加载失败，尝试编译 DPDK 内核模块..."
    cd "$DPDK_DIR/kernel/linux/igb_uio"
    make
    insmod ./igb_uio.ko
fi

# 更新动态链接库
ldconfig

# 检查是否安装成功
if [ -f /usr/local/bin/dpdk-devbind.py ]; then
    echo "==> DPDK 安装成功!"
    echo "你可以运行以下命令绑定网卡: "
    echo "  dpdk-devbind.py --status"
    echo "  dpdk-devbind.py --bind=igb_uio <网卡名>"
else
    echo "错误: DPDK 安装失败!"
    exit 1
fi

exit 0