#!/bin/bash
set -euo pipefail

sgdisk -z -o "$1"		 # clear
sgdisk -n 0:0:+1M -t 0:ef02 "$1" # grub boot
sgdisk -n 0:0:0 -t 0:ef00 "$1"	 # data and efi
sgdisk -h 2 "$1"		 # hybrid main
sfdisk -Y dos -A "$1" 2		 # bootable main
sudo partprobe

# setup loopback
f="$1"
[ -b "$1" ] || f="$(sudo losetup -f "$f")"

# make filesystem on 2nd partition
secondpart="$(lsblk -no pkname,kname | awk "/[^0-9]2\$/&&\$1==\"$(lsblk -no kname "$f")\"{print \$2}")"
sudo mkfs.fat /dev/"$secondpart"

sudo mount "$f" /mnt
sudo cp -r "$(dirname "$0")"/*.sh /mnt/
sudo umount "$f"

losetup -d "$f"
