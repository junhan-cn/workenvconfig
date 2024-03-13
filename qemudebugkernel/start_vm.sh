#!/bin/bash 
# configure

pwdpath=$(dirname "$(realpath "$0")")

configuration=${pwdpath}/config.json

qemudir=$(jq -r ".qemu_dir" < $configuration)
kerneldir=$(jq -r ".kernel_dir" < $configuration)
initrddir=$(jq -r ".initrddir" < $configuration)

basecmd="$qemudir/qemu-system-x86_64 \
     -nographic -m 1024M \
     -kernel $kerneldir/arch/x86/boot/bzImage \
     -hda $initrddir/initrd.img \
     -append 'noapic root=/dev/sda rw console=ttyS0 earlycon=ttyS0 earlyprint ignore_loglevel'"

if [[ $1 == '--debug' ]]; then
	cmd="$basecmd -S -s"
else
	cmd="$basecmd"
fi

eval $cmd
