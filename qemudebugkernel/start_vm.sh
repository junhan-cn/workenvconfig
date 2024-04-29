#!/bin/bash 
# configure

pwdpath=$(dirname "$(realpath "$0")")

configuration=${pwdpath}/config.json

qemudir=$(jq -r ".qemu_dir" < $configuration)
kerneldir=$(jq -r ".kernel_dir" < $configuration)
initrddir=$(jq -r ".initrddir" < $configuration)
qcowdir=$(jq -r ".qcowdir" < $configuration)

debug_kernel() {
	cmd="$qemudir/qemu-system-x86_64 \
		-nographic -m 1024M \
		-kernel $kerneldir/arch/x86/boot/bzImage \
		-hda $initrddir/initrd.img \
		-append 'noapic root=/dev/sda rw console=ttyS0 earlycon=ttyS0 earlyprint ignore_loglevel'"

	eval $cmd
}

start_vm() {
	cmd="$qemudir/qemu-system-x86_64 -name hanzj-test \
		 -machine pc -m size=16g -smp 8  \
		 -drive file=$qcowdir/openEuler-22.03-LTS-SP3-x86_64.qcow2,format=qcow2,if=none,id=disk0 \
		 -device virtio-blk-pci,drive=disk0 \
		 -vnc :2000 -device cirrus-vga,id=video0 -monitor stdio"

	eval $cmd
}

if [[ $1 == '--debug_kernel' ]]; then
	debug_kernel
fi

if [[ $1 == '--debug_vm' ]]; then
	start_vm
fi
