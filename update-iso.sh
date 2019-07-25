#!/bin/sh
set -e

# look at device
d="$(dirname "$0")"
fsdev="$(df -P "$d" | awk 'END{print $1}')"
fsuuid="$(lsblk "$fsdev" -no uuid)"
bootdev="$(lsblk "$fsdev" -no pkname)"

bsdtar -x --exclude=isolinux/ -f "$1" -C "$d"
find "$d"/arch/boot/syslinux "$d"/loader -type f -print0 |
    xargs -0 sed -i "s|archisolabel=\w*|archisodevice=/dev/disk/by-uuid/$fsuuid|g"

# bios compatibility
extlinux -i "$d"/arch/boot/syslinux
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of=/dev/"$bootdev"
