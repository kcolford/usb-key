#!/bin/bash
set -euo pipefail

bsdtar -x -f "$1" -C "$(dirname "$0")"

# bios compatibility
extlinux -i "$(dirname "$0")"/arch/boot/syslinux
read -r fsdev < <(df -P "$0" | awk 'END{print $1}')
read -r bootdev < <(lsblk "$fsdev" -no pkname)
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of=/dev/"$bootdev"
