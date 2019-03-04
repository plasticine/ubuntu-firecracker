#! /bin/bash
set -ex

rm -rf /output/*

cp /root/linux-source-$KERNEL_SOURCE_VERSION/vmlinux /output/vmlinux
cp /root/linux-source-$KERNEL_SOURCE_VERSION/.config /output/config

truncate -s 1G /output/image.ext4
mkfs.ext4 /output/image.ext4

if mountpoint -q /rootfs; then
    umount /rootfs
fi

mount /output/image.ext4 /rootfs

debootstrap \
    --include openssh-server,netplan.io,nano,gnupg \
    bionic \
    /rootfs \
    http://archive.ubuntu.com/ubuntu/

mount --bind / /rootfs/mnt/
mount --bind /script/ /rootfs/mnt/script/

chroot /rootfs /bin/bash /mnt/script/provision.sh

umount /rootfs/mnt/script
umount /rootfs/mnt
umount -l /rootfs

cd /output
tar czvf ubuntu-bionic.tar.gz image.ext4 vmlinux config
cd /
