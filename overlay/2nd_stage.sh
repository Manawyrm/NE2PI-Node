#!/bin/bash

apt update
apt dist-upgrade -y
apt -o Dpkg::Options::="--force-confold" -y install i2c-tools mpg123 vlc openbox xorg unclutter git php-cli php-fpm nginx pigz telnet

# Evil hack: libgtk-3-0 seems to be broken/have a dependency conflict at the time of writing
mv /etc/apt/sources.list.d/raspi.list /etc/apt/raspi.list.disabled
apt update
apt -o Dpkg::Options::="--force-confold" -y install lightdm-gtk-greeter lightdm
mv /etc/apt/raspi.list.disabled /etc/apt/sources.list.d/raspi.list
apt update

chown -hR root:root /etc/lightdm/lightdm.conf

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

# Install raspi-teletext
git clone --depth=1 https://github.com/ali1234/raspi-teletext.git /opt/raspi-teletext
cd /opt/raspi-teletext
make -j 16
