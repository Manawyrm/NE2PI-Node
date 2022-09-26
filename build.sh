#!/bin/bash

# DO NOT EXECUTE ON YOUR LOCAL MACHINE!
#
# Use docker or something similar!
# 
# docker run --rm -it --privileged -v /dev:/dev -v /home/tobias/Entwicklung/Code/TVPI/node_fs_build/:/build --entrypoint bash debian:bullseye-slim
# 

IMAGE_URL="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-09-07/2022-09-06-raspios-bullseye-armhf-lite.img.xz"

apt update
apt dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt -y install git build-essential wget qemu qemu-user-static binfmt-support libarchive-tools qemu-utils sudo rsync nano dosfstools pigz fdisk xz-utils p7zip-full

update-binfmts --enable qemu-arm

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="${SCRIPT_DIR}/build"
ROOT_DIR="${SCRIPT_DIR}/build/root"

mkdir /mount
mkdir -p "${BUILD_DIR}"
mkdir -p "${ROOT_DIR}"

cd ${BUILD_DIR}

# # Download a fresh raspios_lite_armhf (32bit)
# wget -O raspios.img.xz $IMAGE_URL
# 
# # Extract .xz
# xz -d raspios.img.xz
# 
# # Extract MBR SD card image into 0.fat (/boot) and 1.img (/)
# 7z x raspios.img
# rm raspios.img
# 

# Copy root FS
mount -o loop 1.img /mount
rsync -aAXv /mount/ "${ROOT_DIR}"/
umount /mount

# Copy FAT32 config FS
mount -o loop 0.fat /mount
rsync -aAXv /mount/ "${ROOT_DIR}"/boot/
umount /mount

# Copy our files into the FS
rsync -a ${SCRIPT_DIR}/overlay/. "${ROOT_DIR}"

# Bind-mounts for our system / chroot
mount -t proc /proc "${ROOT_DIR}/proc/"
mount --rbind /sys "${ROOT_DIR}/sys/"
mount --rbind /dev "${ROOT_DIR}/dev/"

# Run armhf 2nd stage script (apt, initramfs, etc.)
chroot "${ROOT_DIR}" /2nd_stage.sh

# Unmount everything again
umount -fl "${ROOT_DIR}/proc"
umount -fl "${ROOT_DIR}/sys"
umount -fl "${ROOT_DIR}/dev"

umount "${ROOT_DIR}/proc"
umount "${ROOT_DIR}/sys"
umount "${ROOT_DIR}/dev"