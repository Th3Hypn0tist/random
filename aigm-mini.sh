#!/bin/bash
set -e

DISK=/dev/sda

echo "[1/12] Partitioning disk…"
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary ext4 1MiB 100%

mkfs.ext4 ${DISK}1
mount ${DISK}1 /mnt/gentoo

echo "[2/12] Downloading stage3…"
cd /mnt/gentoo
STAGE3=$(curl -s https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64.txt | awk '!/#/ {print $1}')
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/${STAGE3}
tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner

echo "[3/12] Preparing chroot…"
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

echo "[4/12] Entering chroot to install system…"
cat << 'EOF' > /mnt/gentoo/aigm-mini-install.sh
#!/bin/bash
set -e

source /etc/profile

echo "[5/12] Syncing portage…"
emerge-webrsync

echo "[6/12] Installing kernel and tools…"
emerge gentoo-kernel-bin git python jq cmake nano

echo "[7/12] Creating AIGM directory structure…"
mkdir -p /aigm/{tui,llm,sessions,users,config,monitor}

echo "[8/12] Installing GRUB…"
echo 'GRUB_PLATFORMS="pc"' >> /etc/portage/make.conf
emerge grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "[9/12] Creating user…"
useradd -m aigm
echo "aigm:aigm" | chpasswd

echo "[10/12] Installing llama.cpp…"
cd /aigm/llm
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make -j4

echo "[11/12] Creating tiny TUI…"
cat << 'EOT' > /aigm/tui/tui.py
while True:
    try:
        msg = input("AIGM-mini > ")
        echo(f"[echo] {msg}")
    except EOFError:
        break
EOT

chmod +x /aigm/tui/tui.py

echo "[12/12] Installation complete!"
echo "Reboot and remove LiveCD."
EOF

chmod +x /mnt/gentoo/aigm-mini-install.sh
chroot /mnt/gentoo /aigm-mini-install.sh
rm /mnt/gentoo/aigm-mini-install.sh
umount -l /mnt/gentoo/{proc,sys,dev} || true
umount -l /mnt/gentoo
echo "DONE — reboot system and remove LiveCD."
