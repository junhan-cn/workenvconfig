#!/bin/bash

set -e

PWD_PATH=$(dirname "$(realpath "$0")")
INITRAMFS_PATH="${PWD_PATH}/busybox-initramfs/initramfs.cpio.gz"
JSON_FILE="config.json"

# 默认版本（可根据需要修改为最新稳定版）
DEFAULT_KERNEL_VERSION="6.10.6"
DEFAULT_QEMU_VERSION="8.2.9"

KERNEL_VERSION="${KERNEL_VERSION:-$DEFAULT_KERNEL_VERSION}"
QEMU_VERSION="${QEMU_VERSION:-$DEFAULT_QEMU_VERSION}"

# 支持命令行参数指定版本
while [[ $# -gt 0 ]]; do
    case $1 in
        --kernel)
            KERNEL_VERSION="$2"
            shift 2
            ;;
        --qemu)
            QEMU_VERSION="$2"
            shift 2
            ;;
        build|kernel|qemu|config|clean|help)
            CMD="$1"
            shift
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

KERNEL_FILE="linux-${KERNEL_VERSION}"
KERNEL_FILEGZ="${KERNEL_FILE}.tar.gz"
QEMU_FILE="qemu-${QEMU_VERSION}"
QEMU_FILEXZ="${QEMU_FILE}.tar.xz"
KERNEL_PATH="${PWD_PATH}/${KERNEL_FILE}/arch/x86/boot/bzImage"
QEMU_PATH="${PWD_PATH}/${QEMU_FILE}/build/qemu-system-x86_64"

check_deps() {
    for cmd in wget jq; do
        if ! command -v $cmd &>/dev/null; then
            echo "缺少依赖: $cmd，请先安装。"
            exit 1
        fi
    done
}

install_build_deps() {
    if [ -f '/etc/fedora-release' ]; then
        sudo dnf install -y gcc make flex bison openssl-devel elfutils-libelf-devel ncurses-devel jq
    elif [ -f "/etc/arch-release" ]; then
        sudo pacman -Sy --noconfirm base-devel bc coreutils cpio gettext initramfs kmod libelf ncurses pahole perl python rsync tar xz
    fi
}

buildkernel() {
    install_build_deps
    if [ ! -f "$KERNEL_FILEGZ" ]; then
        wget --user-agent="Mozilla" https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/$KERNEL_FILEGZ
    fi
    if [ ! -d "$KERNEL_FILE" ]; then
        tar -xf "$KERNEL_FILEGZ"
        cd "$KERNEL_FILE"
        make defconfig
        sed -i 's/# CONFIG_DEBUG_INFO_DWARF4 is not set/CONFIG_DEBUG_INFO_DWARF4=y/' .config
        sed -i 's/# CONFIG_XFS_FS is not set/CONFIG_XFS_FS=y/' .config
        yes '' | make oldconfig
        make -j$(nproc)
        cd "$PWD_PATH"
    fi
    echo "内核已构建: $KERNEL_PATH"
}

buildqemu() {
    local retries=5
    local sleep_time=5
    for ((i=1; i<=retries; i++)); do
        if [ ! -f "$QEMU_FILEXZ" ]; then
            wget --no-check-certificate https://download.qemu.org/$QEMU_FILEXZ && break
        else
            break
        fi
        echo "下载失败，$sleep_time 秒后重试..."
        sleep $sleep_time
    done
    if [ ! -d "$QEMU_FILE" ]; then
        tar -xf "$QEMU_FILEXZ"
        cd "$QEMU_FILE"
        mkdir -p build
        cd build
        ../configure --target-list=x86_64-softmmu --enable-kvm --enable-debug --enable-debug-info --enable-modules --enable-vnc --enable-trace-backends=log --disable-werror --disable-strip
        make -j$(nproc)
        cd "$PWD_PATH"
    fi
    echo "QEMU已构建: $QEMU_PATH"
}

genConfig() {
    jq -n --arg kernel "$KERNEL_PATH" --arg qemu "$QEMU_PATH" --arg initramfs "$INITRAMFS_PATH" \
        '{kernel_path: $kernel, qemu_path: $qemu, initramfs_path: $initramfs}' > "$JSON_FILE"
    echo "参数已写入 $JSON_FILE"
}

clean() {
    rm -rf "$KERNEL_FILEGZ" "$KERNEL_FILE" "$QEMU_FILEXZ" "$QEMU_FILE"
    echo "已清理构建文件"
}

help() {
    cat <<EOF
用法: $0 [build|kernel|qemu|config|clean|help] [--kernel 版本] [--qemu 版本]
  build    构建内核和QEMU
  kernel   仅构建内核
  qemu     仅构建QEMU
  config   生成config.json
  clean    清理构建文件
  help     显示帮助信息
  --kernel 指定内核版本（如 --kernel 6.10.6）
  --qemu   指定QEMU版本（如 --qemu 8.2.9）
EOF
}

main() {
    check_deps
    case "$CMD" in
        build) buildkernel; buildqemu; genConfig ;;
        kernel) buildkernel ;;
        qemu) buildqemu ;;
        config) genConfig ;;
        clean) clean ;;
        help|*) help ;;
    esac
}

main "$@"
