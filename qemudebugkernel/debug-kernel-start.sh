#!/bin/bash 

if [[ $2 == "hda" ]];then
	qemu-system-x86_64  -m 1024M -smp 4 -kernel $1/arch/x86/boot/bzImage -append "nokaslr root=/dev/sda console=ttyS0 init=/bin/bash"  -hda rootfs.img --nographic -S -s
else
	qemu-system-x86_64 -kernel $1/arch/x86/boot/bzImage -initrd $2 -nographic -append "console=ttyS0 earlycon=ttyS0 earlyprintk ignore_loglevel nokaslr" -S -s 
fi



