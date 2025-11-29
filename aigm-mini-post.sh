#!/bin/bash
set -euo pipefail

# === CONFIG ==========================================================
DISK="${DISK:-/dev/sda}"   # Sama levy kuin pre-skriptissä (BIOS/legacy boot)
# =====================================================================

echo "[P0] Sanity checks"

# Varmista, että levy on olemassa
if [ ! -b "${DISK}" ]; then
  echo "[ERROR] ${DISK} is not a block device."
  echo "        Set DISK=/dev/sdX when running this script."
  exit 1
fi

# Tämä skripti on BIOS-bootille, ei UEFI:lle
if [ -d /sys/firmware/efi ]; then
  echo "[ERROR] Detected EFI firmware (/sys/firmware/efi exists)."
  echo "        This script is written for legacy BIOS GRUB (i386-pc)."
  echo "        Configure UEFI bootloader manually following the Handbook."
  exit 1
fi

echo "[C2] Root & aigm user (passwords MUST be changed after first login)"
echo "root:root" | chpasswd
if ! id aigm >/dev/null 2>&1; then
  useradd -m -G wheel aigm
fi
echo "aigm:aigm" | chpasswd

echo "[C3] Sudoers (hardened: NO NOPASSWD)"
mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/00-wheel
chmod 440 /etc/sudoers.d/00-wheel

echo "[D0] FI keyboard layout"
mkdir -p /etc/conf.d
echo 'KEYMAP="fi"' > /etc/conf.d/keymaps
rc-update add keymaps default 2>/dev/null || true

echo "[D1] Hardened sysctl tunables"
/bin/mkdir -p /etc/sysctl.d
cat > /etc/sysctl.d/99-aigm-hardened.conf <<EOF4
# AIGM-mini hardened baseline

# IMPORTANT:
# kernel.modules_disabled=1 cannot be enabled inside chroot or before first boot.
# Uncomment after system boots with correct initramfs.
# kernel.modules_disabled = 1

# Restrict kernel pointer exposure
kernel.kptr_restrict = 2

# Restrict dmesg to root
kernel.dmesg_restrict = 1

# Prevent core dumps of setuid binaries
fs.suid_dumpable = 0

# Basic ptrace restriction
kernel.yama.ptrace_scope = 1

# Reverse path filtering (anti-spoof)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF4

echo "[D2] Initramfs (optional, if gentoo-kernel tools exist)"
if [ -x /usr/share/gentoo-kernel/initramfs.sh ]; then
  /usr/share/gentoo-kernel/initramfs.sh || echo "  [WARN] initramfs.sh returned non-zero."
else
  echo "  [WARN] /usr/share/gentoo-kernel/initramfs.sh not found."
  echo "        Make sure you have installed a kernel (e.g. gentoo-kernel-bin)"
  echo "        according to the Gentoo Handbook before relying on this step."
fi

echo "[D3] GRUB install (BIOS mode) if GRUB is installed"
if command -v grub-install >/dev/null 2>&1; then
  grub-install --target=i386-pc "${DISK}"
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "  [WARN] grub-install not found in PATH."
  echo "        Install sys-boot/grub and then run:"
  echo "          grub-install --target=i386-pc ${DISK}"
  echo "          grub-mkconfig -o /boot/grub/grub.cfg"
fi

echo "[E1] AIGM directory structure"
/bin/mkdir -p /aigm/{tui,llm,sessions,users,config,monitor}

echo "[E2] Tiny Python TUI (non-root)"
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

echo "[E3] Harden permissions for /aigm and TUI user"
chown -R aigm:aigm /aigm
chmod -R 750 /aigm

# Auto-start TUI for aigm user on login
mkdir -p /home/aigm
chown aigm:aigm /home/aigm
cat >> /home/aigm/.bash_profile << 'EOF5'
if [ -x /aigm/tui/tui.py ]; then
    /aigm/tui/tui.py
fi
EOF5
chown aigm:aigm /home/aigm/.bash_profile

echo "[F1] OpenRC services"
rc-update add sshd default 2>/dev/null || true

echo
echo "[DONE] AIGM-mini hardened base install complete."
echo "IMPORTANT:"
echo "  - Change passwords for 'root' and 'aigm' immediately after first login."
echo "  - Verify kernel and GRUB are installed/configured as per Gentoo Handbook."
echo
echo "You can now exit chroot, unmount, and reboot (from LiveCD):"
echo "  umount -l /mnt/gentoo/dev"
echo "  umount -l /mnt/gentoo/sys"
echo "  umount -l /mnt/gentoo/proc"
echo "  umount -R /mnt/gentoo || umount -l /mnt/gentoo"
echo "  reboot"
