#!/bin/bash
set -e

DISK=/dev/sda
PART=${DISK}1
MNT=/mnt/gentoo
STATE="$MNT/.AIGM/state"

step_done() {
    [[ -f "$STATE/$1" ]]
}

mark_done() {
    mkdir -p "$STATE"
    touch "$STATE/$1"
}

echo "[STEP 1] Partitioning disk $DISK"
# Jos sda1 on jo olemassa → skippaa
if lsblk | grep -q "^sda1"; then
    echo "→ skip (partition already exists)"
else
    echo "→ creating GPT partition table and partition 'aigm'"
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary ext4 1MiB 100%
    parted -s "$DISK" name 1 aigm
fi

echo "[STEP 2] Creating ext4 filesystem labeled 'aigm'"
if blkid "$PART" 2>/dev/null | grep -q 'TYPE="ext4"'; then
    echo "→ skip (ext4 already present)"
else
    mkfs.ext4 -L aigm "$PART"
fi

echo "[STEP 3] Mounting root to $MNT"
mkdir -p "$MNT"
if mount | grep -q "on $MNT "; then
    echo "→ already mounted"
else
    mount "$PART" "$MNT"
fi

mkdir -p "$STATE"

echo "[STEP 4] Download + extract stage3"
if [ -f "$MNT/etc/gentoo-release" ]; then
    echo "→ stage3 already extracted, skipping"
    mark_done "step4"
elif step_done "step4"; then
    echo "→ step4 already marked done"
else
    cd "$MNT"
    STAGE3=$(curl -s https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-openrc.txt \
      | awk '!/^#/ {print $1; exit}')
    echo "[DEBUG] Stage3: $STAGE3"
    wget https://distfiles.gentoo.org/releases/amd64/autobuilds/${STAGE3}
    tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner
    mark_done "step4"
fi

echo "[STEP 5] Bind mounts (proc/sys/dev)"
if step_done "step5"; then
    echo "→ skip (already done)"
else
    mount -t proc /proc "$MNT/proc"
    mount --rbind /sys "$MNT/sys"
    mount --make-rslave "$MNT/sys"
    mount --rbind /dev "$MNT/dev"
    mount --make-rslave "$MNT/dev"
    mark_done "step5"
fi

echo "[STEP 6] Writing chroot installer"
if step_done "step6"; then
    echo "→ skip (already done)"
else
cat << 'CHROOTEOF' > /mnt/gentoo/aigm-final.sh
#!/bin/bash
set -e

STATE="/.AIGM/state"
mkdir -p "$STATE"

chg_done() {
    [[ -f "$STATE/$1" ]]
}
chg_mark() {
    touch "$STATE/$1"
}

source /etc/profile

echo "[A1] emerge-webrsync"
if chg_done "A1"; then
    echo "→ skip"
else
    emerge-webrsync
    chg_mark "A1"
fi

echo "[A2] base system packages"
if chg_done "A2"; then
    echo "→ skip"
else
    emerge --quiet-build=y gentoo-kernel-bin grub sudo nano python jq cmake git
    chg_mark "A2"
fi

echo "[B1] fstab (LABEL=aigm)"
if chg_done "B1"; then
    echo "→ skip"
else
    echo "LABEL=aigm   /   ext4   noatime   0 1" > /etc/fstab
    chg_mark "B1"
fi

echo "[B2] hostname"
if chg_done "B2"; then
    echo "→ skip"
else
    echo "hostname=\"aigm-mini\"" > /etc/conf.d/hostname
    chg_mark "B2"
fi

echo "[B3] network setup (eth0 dhcp)"
if chg_done "B3"; then
    echo "→ skip"
else
    echo 'config_eth0="dhcp"' > /etc/conf.d/net
    ln -sf /etc/init.d/net.lo /etc/init.d/net.eth0
    rc-update add net.eth0 default
    chg_mark "B3"
fi

echo "[C1] root password"
if chg_done "C1"; then
    echo "→ skip"
else
    echo "root:root" | chpasswd
    chg_mark "C1"
fi

echo "[C2] timezone"
if chg_done "C2"; then
    echo "→ skip"
else
    echo "UTC" > /etc/timezone
    emerge --config sys-libs/timezone-data
    chg_mark "C2"
fi

echo "[C3] locale"
if chg_done "C3"; then
    echo "→ skip"
else
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    eselect locale set en_US.utf8
    chg_mark "C3"
fi

echo "[D1] initramfs"
if chg_done "D1"; then
    echo "→ skip"
else
    /usr/share/gentoo-kernel/initramfs.sh || true
    chg_mark "D1"
fi

echo "[D2] grub-install"
if chg_done "D2"; then
    echo "→ skip"
else
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
    chg_mark "D2"
fi

echo "[E1] AIGM directories"
if chg_done "E1"; then
    echo "→ skip"
else
    mkdir -p /aigm/{tui,llm,sessions,users,config,monitor}
    chg_mark "E1"
fi

echo "[E2] user 'aigm'"
if chg_done "E2"; then
    echo "→ skip"
else
    useradd -m -G wheel aigm
    echo "aigm:aigm" | chpasswd
    mkdir -p /etc/sudoers.d
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00-wheel
    chg_mark "E2"
fi

echo "[E3] tiny TUI"
if chg_done "E3"; then
    echo "→ skip"
else
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
chg_mark "E3"
fi

echo "[DONE] chroot install finished"
CHROOTEOF

chmod +x "$MNT/aigm-final.sh"
mark_done "step6"
fi

echo "[STEP 7] Chroot installer run"
chroot "$MNT" /aigm-final.sh || echo "[ERR] chroot installer failed"

echo "[STEP 8] Unmounting"
umount -l "$MNT/dev" || true
umount -l "$MNT/sys" || true
umount -l "$MNT/proc" || true
umount -l "$MNT" || true

echo "[COMPLETE] AIGM-mini installed — reboot and boot from disk."
