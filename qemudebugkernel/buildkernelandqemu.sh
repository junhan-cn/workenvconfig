#!/bin/bash 

pwdpath=$(dirname "$(realpath "$0")")
kernelpath="/nvme-volume/hanzj/workenvconfig/qemudebugkernel/bzImage"
qemupath="/usr/bin/qemu-system-x86_64"
JSON_FILE="config.json"

#chose 6.10.6 version

buildkernel() {
	if [ -f '/etc/fedora-release' ];then
		sudo dnf install gcc make flex bison openssl-devel elfutils-libelf-devel ncurses-devel jq
	elif [ -f "/etc/arch-release" ] ;then
		sudo pacman -Sy base-devel bc coreutils cpio gettext initramfs kmod libelf ncurses pahole perl python rsync tar xz
	fi

	if [ ! -f 'linux-6.10.6.tar.gz' ];then
		wget --user-agent="Mozilla" https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-6.10.6.tar.gz
	fi

	if [ ! -d 'linux-6.10.6' ];then
		tar -xvf linux-6.10.6.tar.gz
		cd linux-6.10.6 && make x86_64_defconfig && make -j$(nproc)
		kernelpath=$(pwd)/arch/x86/boot/bzImage
		cd $pwdpath
	else
	     kernelpath=$(pwd)/linux-6.10.6/arch/x86/boot/bzImage
	fi
}


buildqemu() {
	if [ ! -f 'qemu-6.2.0.tar.xz' ];then
		wget https://download.qemu.org/qemu-6.2.0.tar.xz
	fi

	if [ ! -d 'qemu-6.2.0' ];then
		tar -xvf qemu-6.2.0.tar.xz
		cd qemu-6.2.0 && mkdir build && \
		cd build && ../configure --target-list=x86_64-softmmu \
		--enable-kvm --enable-debug --enable-debug-info --enable-modules \
		--enable-vnc --enable-trace-backends=log --disable-werror --disable-strip
		make -j$(nproc)
		qemupath=$(pwd)/qemu-system-x86_64
		cd $pwdpath
	else
		qemupath=$(pwd)/qemu-6.2.0/build/qemu-system-x86_64
	fi
}

genConfig() {
	if ! command -v jq &> /dev/null
	then
		echo "jq未安装，请先安装jq."
	fi

	if [ -f "$JSON_FILE" ]; then
     		jq --arg p1 "$kernelpath" --arg p2 "$qemupath" '. + {kernelpath: $p1, qemupath: $p2}' "$JSON_FILE" > temp.json
			mv temp.json "$JSON_FILE"
	else
		jq -n --arg p1 "$kernelpath" --arg p2 "$qemupath" '{kernelpath: $p1, qemupath: $p2}' > "$JSON_FILE"
	fi

	echo "参数已成功写入 $JSON_FILE"

}


buildkernel
buildqemu
genConfig
