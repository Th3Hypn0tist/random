#!/bin/bash
set -e

DISK=/dev/sda
PART=${DISK}1
MNT=/mnt/gentoo

echo "[0] HARD WIPE /dev/sda (partition table & first 10MB)"
wipefs -a "$DISK" || true
dd if=/dev/zero of="$DISK" bs=1M count=10 status=none || true
partprobe "$DISK" || true

echo "[1] Create GPT + single ext4 partition"
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary ext4 1MiB 100%
parted -s "$DISK" name 1 aigm

echo "[2] Format /dev/sda1 as ext4 (LABEL=aigm)"
mkfs.ext4 -L aigm "$PART"

echo "[3] Mount root filesystem"
mkdir -p "$MNT"
mount "$PART" "$MNT"

echo "[4] Download & extract Gentoo stage3 (amd64 openrc)"
cd "$MNT"
STAGE3=$(curl -s https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-openrc.txt | awk '!/^#/ {print $1; exit}')
echo "  -> $STAGE3"
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/${STAGE3}
tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner

echo "[5] Copy DNS & bind-mount /proc /sys /dev"
cp -L /etc/resolv.conf "$MNT/etc/"
mount -t proc /proc "$MNT/proc"
mount --rbind /sys "$MNT/sys"
mount --make-rslave "$MNT/sys"
mount --rbind /dev "$MNT/dev"
mount --make-rslave "$MNT/dev"

echo "[6] Write inner installer (chroot script)"
cat << 'CHROOTEOF' > /mnt/gentoo/aigm-final.sh
#!/bin/bash
set -e

MNT=/
DISK=/dev/sda

echo "[A1] Ensure repos.conf points to /var/db/repos/gentoo"
mkdir -p /var/db/repos
mkdir -p /etc/portage/repos.conf
cat > /etc/portage/repos.conf/gentoo.conf <<EOF2
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
EOF2

echo "[A2] Sync Portage (emerge-webrsync)"
emerge-webrsync

echo "[A3] Fix make.profile symlink (default/linux/amd64/23.0)"
rm -f /etc/portage/make.profile
ln -s /var/db/repos/gentoo/profiles/default/linux/amd64/23.0 /etc/portage/make.profile

echo "[B1] Install base system (kernel, grub, tools)"
emerge --quiet-build=y sys-kernel/gentoo-kernel-bin grub sudo nano python jq cmake git

echo "[B2] fstab using LABEL=aigm"
/bin/echo "LABEL=aigm  /  ext4  noatime  0 1" > /etc/fstab

echo "[B3] Hostname & network"
echo 'hostname="aigm-mini"' > /etc/conf.d/hostname
echo 'config_eth0="dhcp"' > /etc/conf.d/net
ln -sf /etc/init.d/net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default

echo "[C1] Timezone & locale"
echo "UTC" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
eselect locale set en_US.utf8

echo "[C2] Root & aigm user passwords"
echo "root:root" | chpasswd
useradd -m -G wheel aigm || true
echo "aigm:aigm" | chpasswd
mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00-wheel

echo "[D1] Ensure kernel & initramfs installed"
/usr/share/gentoo-kernel/initramfs.sh || true

echo "[D2] Install GRUB to /dev/sda (BIOS mode)"
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "[E1] AIGM directory structure"
/bin/mkdir -p /aigm/{tui,llm,sessions,users,config,monitor}

echo "[E2] Tiny Python TUI"
cat << 'TUIEOF' > /aigm/tui/tui.py
#!/usr/bin/env python3
while True:
    try:
        msg = input("AIGM-mini > ")
        print(f"[echo] {msg}")
    except EOFError:
        break
TUIEOF
chmod +x /aigm/tui/tui.py

echo "[DONE] AIGM-mini base install complete."
CHROOTEOF

chmod +x /mnt/gentoo/aigm-final.sh

echo "[7] Enter chroot & run inner installer"
chroot "$MNT" /aigm-final.sh

echo "[8] Cleanup & unmount"
umount -l "$MNT/dev" || true
umount -l "$MNT/sys" || true
umount -l "$MNT/proc" || true
umount -l "$MNT" || true

echo "[OK] AIGM-mini installed. Reboot, remove LiveCD and login:"
echo "  root / root   or   aigm / aigm"
