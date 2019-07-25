#!/bin/bash
set -euo pipefail

sgdisk -o "$1"			 # clear
sgdisk -n 0:0:+1M -t 0:ef02 "$1" # grub boot
sgdisk -n 0:0:0 -t 0:ef00 "$1"	 # data and efi
sgdisk -h 2 "$1"		 # hybrid main
sfdisk -Y dos -A "$1" 2		 # bootable main
