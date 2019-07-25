#!/bin/bash
set -euo pipefail

# look at device
d="$(dirname "$0")"
read -r fsdev < <(df -P "$d" | awk 'END{print $1}')
read -r fsuuid < <(lsblk "$fsdev" -no uuid)
read -r bootdev < <(lsblk "$fsdev" -no pkname)

bsdtar -x -f "$1" -C "$d"
sed -i "s|archisolabel=\w*|archisodevice=/dev/disk/by-uuid/$fsuuid|g" "$d"/{arch,loader}/**

# bios compatibility
extlinux -i "$d"/arch/boot/syslinux
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of=/dev/"$bootdev"
