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

boot="$data"/boot

grub-install --target=x86_64-efi --recheck --removable --efi-directory="$efi" --boot-directory="$boot"
grub-install --target=i386-pc --recheck --boot-directory="$boot" "$l"

cat > "$boot"/grub/grub.cfg <<'EOF'
set imgdevpath="/dev/disk/by-label/KCOLFORD"

menuentry 'archiso' {
	set isofile='/boot/archiso.iso'
	loopback loop $isofile
	linux (loop)/arch/boot/x86_64/vmlinuz img_dev=$imgdevpath img_loop=$isofile earlymodules=loop
	initrd (loop)/arch/boot/intel_ucode.img (loop)/arch/boot/amd_ucode.img (loop)/arch/boot/x86_64/archiso.img
}

menuentry 'archboot' {
	set isofile='/boot/archboot.iso'
	loopback loop $isofile
	linux (loop)/boot/vmlinuz_x86_64 iso_loop_dev=$imgdevpath iso_loop_path=$isofile
	initrd (loop)/boot/initramfs_x86_64.img
}
EOF

umount "$p3"
umount "$p2"
[ -b "$1" ] || losetup -d "$l"
