#!/bin/bash
set -euo pipefail

# look at device
d="$(dirname "$0")"
fsdev="$(df -P "$d" | awk 'END{print $1}')"
fsuuid="$(lsblk "$fsdev" -no uuid)"
bootdev="$(lsblk "$fsdev" -no pkname)"

bsdtar -x -f "$1" -C "$d"
sed -i "s|archisolabel=\w*|archisodevice=/dev/disk/by-uuid/$fsuuid|g" "$d"/{arch,loader}/**

# bios compatibility
extlinux -i "$d"/arch/boot/syslinux
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of=/dev/"$bootdev"
