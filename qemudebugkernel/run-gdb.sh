#!/bin/bash
set -e

# 自动检测 vmlinux 路径
pwdpath=$(dirname "$(realpath "$0")")

configuration=${pwdpath}/config.json

VMLINUX=$(jq -r ".vmlinux_path" < $configuration)


cat > debug-kernel.gdb <<EOF
file $VMLINUX
target remote :1234
set confirm off
set pagination off
break start_kernel
break panic
c
EOF

gdb -x debug-kernel.gdb
