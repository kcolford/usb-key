#!/bin/bash
set -euo pipefail

sgdisk -z -o -n 0:0:+1M -t 0:ef02 -n 0:0:+50M -t 0:ef00 -n 0:0:0 -h 1,2,3 "$1"
[ -b "$1" ] && l="$1" || l="$(losetup -f "$1")"
partprobe

p2=/dev/"$(lsblk -no pkname,kname | awk "/[^0-9]2\$/&&\$1==\"$(basename "$l")\"{print \$2}")"
umount "$p2" || :
mkfs.fat -n EFI "$p2"
efi=/run/media/"$USER"/EFI
mount -o X-mount.mkdir "$p2" "$efi"

p3=/dev/"$(lsblk -no pkname,kname | awk "/[^0-9]3\$/&&\$1==\"$(basename "$l")\"{print \$2}")"
umount "$p3" || :
mkfs.fat -n KCOLFORD "$p3"
data=/run/media/"$USER"/KCOLFORD
mount -o X-mount.mkdir "$p3" "$data"

grub-install --target=x86_64-efi --recheck --removable --efi-directory="$efi" --boot-directory="$data"/boot
grub-install --target=i386-pc --recheck --boot-directory="$data"/grub "$l"

umount "$p3"
umount "$p2"
[ -b "$1" ] || losetup -d "$l"
