#!/bin/bash
set -e

DISK=/dev/sda
STATE="/mnt/gentoo/.AIGM/state"
mkdir -p "$STATE"

step_done() {
    [[ -f "$STATE/$1" ]]
}

mark_done() {
    touch "$STATE/$1"
}

# ----------------------
# STEP 1 — Partitioning
# ----------------------
echo "[STEP 1] Partitioning disk"
if step_done "step1"; then
    echo "→ skip (already done)"
else
    parted -s $DISK mklabel gpt
    parted -s $DISK mkpart primary ext4 1MiB 100%
    mark_done "step1"
fi

# ----------------------
# STEP 2 — Filesystem
# ----------------------
echo "[STEP 2] Creating filesystem"
if step_done "step2"; then
    echo "→ skip (already done)"
else
    mkfs.ext4 ${DISK}1
    mark_done "step2"
fi

# ----------------------
# STEP 3 — Mount root
# ----------------------
echo "[STEP 3] Mounting /mnt/gentoo"
mount ${DISK}1 /mnt/gentoo 2>/dev/null || true
if mount | grep -q "/mnt/gentoo"; then
    echo "→ mounted OK"
else
    echo "→ ERROR: mount failed"; exit 1
fi
mark_done "step3"

# ----------------------
# STEP 4 — Stage3
# ----------------------
echo "[STEP 4] Download + extract Stage3"
if step_done "step4"; then
    echo "→ skip (already done)"
else
    cd /mnt/gentoo
    STAGE3=$(curl -s https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-openrc.txt \
      | awk '!/^#/ {print $1; exit}')
    echo "[DEBUG] Stage3: $STAGE3"
    wget https://distfiles.gentoo.org/releases/amd64/autobuilds/${STAGE3}
    tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner
    mark_done "step4"
fi

# ----------------------
# STEP 5 — Bind mounts
# ----------------------
echo "[STEP 5] Bind mounts"
if step_done "step5"; then
    echo "→ skip (already done)"
else
    mount -t proc /proc /mnt/gentoo/proc
    mount --rbind /sys /mnt/gentoo/sys
    mount --make-rslave /mnt/gentoo/sys
    mount --rbind /dev /mnt/gentoo/dev
    mount --make-rslave /mnt/gentoo/dev
    mark_done "step5"
fi

# ----------------------
# STEP 6 — Write chroot installer
# ----------------------
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

# A1 – Portage sync
echo "[A1] emerge-webrsync"
if chg_done "A1"; then
    echo "→ skip"
else
    emerge-webrsync
    chg_mark "A1"
fi

# A2 – Base system install
echo "[A2] base system packages"
if chg_done "A2"; then
    echo "→ skip"
else
    emerge --quiet-build=y gentoo-kernel-bin grub sudo nano python jq cmake git
    chg_mark "A2"
fi

# B1 – fstab
echo "[B1] fstab"
if chg_done "B1"; then
    echo "→ skip"
else
    echo "/dev/sda1   /   ext4   noatime   0 1" > /etc/fstab
    chg_mark "B1"
fi

# B2 – hostname
echo "[B2] hostname"
if chg_done "B2"; then
    echo "→ skip"
else
    echo "hostname=\"aigm-mini\"" > /etc/conf.d/hostname
    chg_mark "B2"
fi

# B3 – network
echo "[B3] network setup"
if chg_done "B3"; then
    echo "→ skip"
else
    echo 'config_eth0="dhcp"' > /etc/conf.d/net
    ln -sf /etc/init.d/net.lo /etc/init.d/net.eth0
    rc-update add net.eth0 default
    chg_mark "B3"
fi

# C1 – root password
echo "[C1] root password"
if chg_done "C1"; then
    echo "→ skip"
else
    echo "root:root" | chpasswd
    chg_mark "C1"
fi

# C2 – timezone
echo "[C2] timezone"
if chg_done "C2"; then
    echo "→ skip"
else
    echo "UTC" > /etc/timezone
    emerge --config sys-libs/timezone-data
    chg_mark "C2"
fi

# C3 – locale
echo "[C3] locale"
if chg_done "C3"; then
    echo "→ skip"
else
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    eselect locale set en_US.utf8
    chg_mark "C3"
fi

# D1 – kernel
echo "[D1] initramfs"
if chg_done "D1"; then
    echo "→ skip"
else
    /usr/share/gentoo-kernel/initramfs.sh || true
    chg_mark "D1"
fi

# D2 – grub
echo "[D2] grub-install"
if chg_done "D2"; then
    echo "→ skip"
else
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
    chg_mark "D2"
fi

# E1 – AIGM dirs
echo "[E1] dirs"
if chg_done "E1"; then
    echo "→ skip"
else
    mkdir -p /aigm/{tui,llm,sessions,users,config,monitor}
    chg_mark "E1"
fi

# E2 – user
echo "[E2] user"
if chg_done "E2"; then
    echo "→ skip"
else
    useradd -m -G wheel aigm
    echo "aigm:aigm" | chpasswd
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00-wheel
    chg_mark "E2"
fi

# E3 – TUI
echo "[E3] TUI"
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

echo "[DONE]"
CHROOTEOF

mark_done "step6"
fi

# ----------------------
# STEP 7 — Chroot & run installer
# ----------------------
echo "[STEP 7] Chroot Installer"
chroot /mnt/gentoo /aigm-final.sh || echo "[ERR] chroot failed"

# ----------------------
# STEP 8 — Unmount
# ----------------------
echo "[STEP 8] Unmounting"
umount -l /mnt/gentoo/dev || true
umount -l /mnt/gentoo/sys || true
umount -l /mnt/gentoo/proc || true
umount -l /mnt/gentoo || true

echo "[COMPLETE] AIGM-mini installed — reboot!"
