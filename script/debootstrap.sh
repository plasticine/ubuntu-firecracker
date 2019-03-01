#! /bin/bash
set -ex

if [[ ! -e /output/vmlinux ]]; then
    cp /root/linux-source-$KERNEL_SOURCE_VERSION/vmlinux /output/vmlinux
fi

if [[ ! -e /output/config ]]; then
    cp /root/linux-source-$KERNEL_SOURCE_VERSION/.config /output/config
fi

if [[ ! -e /output/image.ext4 ]]; then
    truncate -s 1G /output/image.ext4
    mkfs.ext4 /output/image.ext4
fi

mount /output/image.ext4 /rootfs

if [ -z "$(ls -A /rootfs)" ]; then
   debootstrap --include openssh-server,netplan.io,nano,gnupg,lsof bionic /rootfs http://archive.ubuntu.com/ubuntu/
fi

mount --bind / /rootfs/mnt
