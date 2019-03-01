#! /bin/bash
set -ex

chroot /rootfs /bin/bash /mnt/script/provision.sh
sleep 30

umount /rootfs/mnt
umount -f /rootfs

cd /output
tar czvf ubuntu-bionic.tar.gz image.ext4 vmlinux config
cd /
