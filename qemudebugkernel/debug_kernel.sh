#!/bin/bash 

pwdpath=$(dirname "$(realpath "$0")")

configuration=${pwdpath}/config.json

qemupath=$(jq -r ".qemu_path" < $configuration)
kernelpath=$(jq -r ".kernel_path" < $configuration)
initramfspath=$(jq -r ".initramfs_path" < $configuration)
debug_kernel() {
	cmd="$qemupath \
		-nographic -m 1024M \
		-kernel $kernelpath \
		-hda $initramfspath\
		-append 'root=/dev/sda  nokaslr noapic console=ttyS0 earlycon=ttyS0 earlyprint ignore_loglevel' -S -s"

	eval $cmd
}

debug_kernel

