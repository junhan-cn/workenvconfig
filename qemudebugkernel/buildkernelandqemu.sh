#!/bin/bash 

PWD_PATH=$(dirname "$(realpath "$0")")
KERNEL_PATH="NULL"
QEMU_PATH="NULL"
JSON_FILE="config.json"

#chose ${KERNEL_VERSION} version
KERNEL_VERSION="6.10.6"
QEMU_VERSION="8.2.9"
KERNEL_FILE="linux-${KERNEL_VERSION}"
KERNEL_FILEGZ="${KERNEL_FILE}.tar.gz"
QEMU_FILE="qemu-${QEMU_VERSION}"
QEMU_FILEXZ=${QEMU_FILE}.tar.xz

buildkernel() {
	if [ -f '/etc/fedora-release' ];then
		sudo dnf install gcc make flex bison \
			openssl-devel elfutils-libelf-devel ncurses-devel jq
	elif [ -f "/etc/arch-release" ] ;then
		sudo pacman -Sy base-devel bc coreutils \
			cpio gettext initramfs kmod libelf ncurses pahole perl python rsync tar xz
	fi

	if [ ! -f "$KERNEL_FILEGZ" ];then
		wget --user-agent="Mozilla" https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-${KERNEL_VERSION}.tar.gz
	fi

	if [ ! -d "$KERNEL_FILE" ];then
		tar -xf linux-${KERNEL_VERSION}.tar.gz
		cd linux-${KERNEL_VERSION} && make defconfig  
		# 开启 debuginfo 相关选项
		sed -i 's/# CONFIG_DEBUG_INFO_DWARF4 is not set/CONFIG_DEBUG_INFO_DWARF4=y/' .config

		# 解决依赖关系
		yes '' | make oldconfig
		make -j$(nproc)
		KERNEL_PATH=$(pwd)/arch/x86/boot/bzImage
		cd $PWD_PATH
	else
		KERNEL_PATH=$(pwd)/linux-${KERNEL_VERSION}/arch/x86/boot/bzImage
	fi
}


buildqemu() {
	if [ ! -f "$QEMU_FILEXZ" ];then
		wget https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz
	fi

	if [ ! -d "$QEMU_FILE" ];then
		tar -xf qemu-${QEMU_VERSION}.tar.xz
		cd qemu-${QEMU_VERSION} && mkdir build && \
			cd build && ../configure --target-list=x86_64-softmmu \
			--enable-kvm --enable-debug --enable-debug-info --enable-modules \
			--enable-vnc --enable-trace-backends=log --disable-werror --disable-strip
		make -j$(nproc)
		QEMU_PATH=$(pwd)/qemu-system-x86_64
		cd $PWD_PATH
	else
		QEMU_PATH=$(pwd)/qemu-${QEMU_VERSION}/build/qemu-system-x86_64
	fi
}

genConfig() {
	if ! command -v jq &> /dev/null
	then
		echo "jq未安装，请先安装jq."
	fi

	if [ -f "$JSON_FILE" ]; then
		jq --arg p1 "$KERNEL_PATH" --arg p2 "$QEMU_PATH" \
			'. + {kernel_path: $p1, qemu_path: $p2}' "$JSON_FILE" > temp.json
		mv temp.json "$JSON_FILE"
	else
		jq -n --arg p1 "$KERNEL_PATH" --arg p2 "$QEMU_PATH" \
			'{kernel_path: $p1, qemu_path: $p2}' > "$JSON_FILE"
	fi

	echo "参数已成功写入 $JSON_FILE"

}

clean() {
 cd $PWD_PATH
 rm -rf $KERNEL_FILEGZ
 rm -rf $KERNEL_FILE
}

help() {

 echo "help"
}


buildkernel
buildqemu
genConfig
