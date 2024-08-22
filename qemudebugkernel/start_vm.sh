#!/bin/bash 

pwdpath=$(dirname "$(realpath "$0")")

configuration=${pwdpath}/config.json

qemupath=$(jq -r ".qemupath" < $configuration)
kernelpath=$(jq -r ".kernelpath" < $configuration)
initrdpath=$(jq -r ".initrdpath" < $configuration)
qcowpath=$(jq -r ".qcowpath" < $configuration)


echo $qemupath
echo $kernelpath
echo $initrdpath
echo $qcowpath
checkqemu() {

	if [[ ! -f "$qemupath" ]];then
		echo "qemu is not"
	fi
}

checkkernel() {
	if [[ ! -f "$kernelpath" ]];then
		echo "kernel is not"
	fi
}

checkinitrd() {
	if [[ ! -f "$initrdpath" ]];then
		echo "initrd is not"
	fi
}

checkqcow() {
	if [[ ! -f "$qcowpath" ]];then
		echo "qcow is not"
	fi
}


debug_kernel() {
	cmd="$qemupath \
		-nographic -m 1024M \
		-kernel $kernelpath \
		-hda $initrdpath\
		-append 'noapic root=/dev/sda rw console=ttyS0 earlycon=ttyS0 earlyprint ignore_loglevel' -S -s "

	eval $cmd
}

start_vm() {
	cmd="$qemupath -name hanzj-test \
		 -machine pc -m size=16g -smp 8  \
		 -drive file=$qcowpath,format=qcow2,if=none,id=disk0 \
		 -device virtio-blk-pci,drive=disk0 \
		 -vnc :2000 -device cirrus-vga,id=video0 -monitor stdio"

	eval $cmd
}

checkqemu
checkkernel
checkqcow
checkinitrd

if [[ $1 == '--debug_kernel' ]]; then
	debug_kernel
fi

if [[ $1 == '--debug_vm' ]]; then
	start_vm
fi
