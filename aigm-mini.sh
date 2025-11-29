#!/bin/bash
set -e

DISK=/dev/sda

echo "[1] Partitioning…"
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary ext4 1MiB 100%

mkfs.ext4 ${DISK}1
mount ${DISK}1 /mnt/gentoo

echo "[2] Fetching stage3…"
cd /mnt/gentoo
STAGE3=$(curl -s https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-openrc.txt | awk '!/^#/ {print $1; exit}')
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/${STAGE3}
tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner

echo "[3] Preparing chroot…"
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

echo "[4] Writing final installer inside chroot…"
cat << 'EOF' > /mnt/gentoo/aigm-final.sh
#!/bin/bash
set -e
source /etc/profile

echo "[A] Portage sync…"
emerge-webrsync

echo "[B] Basic system packages…"
emerge --quiet-build=y gentoo-kernel-bin grub sudo nano python jq cmake git

echo "[C] fstab…"
cat << 'EOT' > /etc/fstab
/dev/sda1   /   ext4   noatime   0 1
EOT

echo "[D] hostname…"
echo "hostname=\"aigm-mini\"" > /etc/conf.d/hostname

echo "[E] networking…"
echo 'config_eth0="dhcp"' > /etc/conf.d/net
ln -s /etc/init.d/net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default

echo "[F] root password…"
echo "root:root" | chpasswd

echo "[G] timezone…"
echo "UTC" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "[H] locale…"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
eselect locale set en_US.utf8

echo "[I] Kernel install ensured…"
/usr/share/gentoo-kernel/initramfs.sh || true

echo "[J] Install GRUB…"
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "[K] AIGM directory structure…"
mkdir -p /aigm/{tui,llm,sessions,users,config,monitor}

echo "[L] Add user…"
useradd -m -G wheel aigm
echo "aigm:aigm" | chpasswd
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00-wheel-nopasswd

echo "[M] Tiny TUI…"
cat << 'EOT2' > /aigm/tui/tui.py
#!/usr/bin/env python3
while True:
    try:
        msg = input("AIGM-mini > ")
        print(f"[echo] {msg}")
    except EOFError:
        break
EOT2
chmod +x /aigm/tui/tui.py

echo "DONE — exit chroot and reboot."
EOF

chmod +x /mnt/gentoo/aigm-final.sh
chroot /mnt/gentoo /aigm-final.sh

echo "[5] Cleaning up & unmounting…"
umount -l /mnt/gentoo/dev || true
umount -l /mnt/gentoo/sys || true
umount -l /mnt/gentoo/proc || true
umount -l /mnt/gentoo || true

echo "AIGM-mini installed — reboot now!"
