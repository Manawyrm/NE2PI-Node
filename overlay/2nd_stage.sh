#!/bin/bash

apt update
DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confold" dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confold" -y install i2c-tools mpg123 vlc openbox xorg lightdm lightdm-gtk-greeter unclutter git php-cli php-fpm nginx pigz telnet
systemctl enable lightdm
systemctl enable nginx
systemctl enable ssh

# Create initramfs (for USB gadget mode ethernet / netbooting)
KERNEL=`ls /lib/modules | head -n 1`
update-initramfs -c -k $KERNEL
mv /boot/initrd.img-$KERNEL /boot/initrd.img

# Set default password
echo "pi:raspberry" | chpasswd

# Generate SSH hostkey
# Yes, this is more than unsafe. There is no security on USB ethernet link anyway
# so SSH should be considered compromised (just like NFS)
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# Disable initial user setup (pi-user, network, locales, etc.)
systemctl disable userconfig.service

# Disable swapping
systemctl disable dphys-swapfile

# Disable logging (nowhere to log on a r/o fs anyway)
systemctl disable rsyslog
systemctl mask syslog.socket

systemctl disable regenerate_ssh_host_keys.service
systemctl disable resize2fs_once.service
systemctl disable plymouth-quit-wait.service
systemctl disable plymouth-read-write.service
systemctl disable plymouth-start.service
systemctl disable raspi-config.service

