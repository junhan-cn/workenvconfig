#!/bin/bash 

pwdpath=$(dirname "$(realpath "$0")")
#chose 6.10.6 version
getkernelcode() {
	if [[ ! -d 'linux-6.10.6' ]];then 
		wget https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-6.10.6.tar.gz 
	fi
 	buildkernel
}

buildkernel() {
		sudo pacman -Sy base-devel bc coreutils cpio gettext initramfs kmod libelf ncurses pahole perl python rsync tar xz
		tar -xvf linux-6.10.6.tar.gz 
		cd linux-6.10.6 && make x86_64_defconfig && make -j8
		cd $pwdpath 
}


getqemucode() {
	if [[ ! -d 'qemu-6.2.0' ]];then
		wget https://download.qemu.org/qemu-6.2.0.tar.xz
	fi
	buildqemu
}

buildqemu() {
	tar -xvf qemu-6.2.0.tar.xz
	cd qemu-6.2.0 && mkdir build && cd build && ../configure --target-list=x86_64-softmmu --enable-kvm --enable-debug --enable-debug-info --enable-modules --enable-vnc --enable-trace-backends=log --disable-werror --disable-strip
	make -j8
    cd $pwdpath	
}

clean() {
	rm qemu-6.2.0.tar.xz
	rm linux-6.10.6.tar.gz
}


getkernelcode
getqemucode
clean
