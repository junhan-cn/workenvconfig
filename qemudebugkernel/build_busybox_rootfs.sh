#!/bin/bash
set -e

BUSYBOX_VERSION=1.36.1
ROOTFS_DIR=$(pwd)/busybox-rootfs
IMG_FILE=$(pwd)/rootfs.img
IMG_SIZE=64M

if command -v apt >/dev/null 2>&1; then
	    sudo apt update
		    sudo apt install -y build-essential wget qemu-utils libncurses-dev
		elif command -v dnf >/dev/null 2>&1; then
			    sudo dnf install -y gcc make wget qemu-img ncurses-devel
fi

if [ ! -f busybox-$BUSYBOX_VERSION.tar.bz2 ]; then
	    wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
fi
tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
cd busybox-$BUSYBOX_VERSION
make distclean
make defconfig
sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/' .config
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make -j$(nproc)
make CONFIG_PREFIX=../_install install
cd ..

rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR
cp -r _install/* $ROOTFS_DIR
mkdir -p $ROOTFS_DIR/{proc,sys,dev,etc,tmp}

cat > $ROOTFS_DIR/init <<'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
echo "Welcome to BusyBox rootfs (no password)"
exec /bin/sh
EOF
chmod +x $ROOTFS_DIR/init

cat > $ROOTFS_DIR/etc/passwd <<'EOF'
root:x:0:0:root:/root:/bin/sh
EOF

cat > $ROOTFS_DIR/etc/shadow <<'EOF'
root::18742:0:99999:7:::
EOF

cat > $ROOTFS_DIR/etc/group <<'EOF'
root:x:0:
EOF

sudo mknod -m 600 $ROOTFS_DIR/dev/console c 5 1
sudo mknod -m 666 $ROOTFS_DIR/dev/null c 1 3

rm -f $IMG_FILE
qemu-img create $IMG_FILE $IMG_SIZE
mkfs.ext4 -F $IMG_FILE

mkdir -p mnt
sudo mount -o loop $IMG_FILE mnt
sudo cp -a $ROOTFS_DIR/* mnt
sudo umount mnt
rm -rf mnt

echo "[+] rootfs.img 已生成: $IMG_FILE"

