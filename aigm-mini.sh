echo "[C2] Root & aigm user (passwords MUST be changed after first login)"
echo "root:root" | chpasswd
useradd -m -G wheel aigm || true
echo "aigm:aigm" | chpasswd

echo "[C3] Sudoers (hardened: NO NOPASSWD)"
mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/00-wheel
chmod 440 /etc/sudoers.d/00-wheel

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

echo "[D2] Ensure kernel & initramfs installed"
/usr/share/gentoo-kernel/initramfs.sh || true

echo "[D3] Install GRUB to ${DISK} (BIOS mode)"
grub-install --target=i386-pc "$DISK"
grub-mkconfig -o /boot/grub/grub.cfg

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

echo "[DONE] AIGM-mini hardened base install complete."
echo "IMPORTANT: Change passwords for 'root' and 'aigm' immediately after first login."
CHROOTEOF

chmod +x "$MNT/aigm-final.sh"

echo "[7] Enter chroot & run inner installer"
chroot "$MNT" /aigm-final.sh

echo "[8] Cleanup & unmount"
umount -l "$MNT/dev" || true
umount -l "$MNT/sys" || true
umount -l "$MNT/proc" || true
umount -R "$MNT" || umount -l "$MNT" || true

echo "[OK] AIGM-mini hardened installed."
echo "Next steps:"
echo "  1) Reboot and remove LiveCD."
echo "  2) Login as:   root / root   OR   aigm / aigm"
echo "  3) IMMEDIATELY change both passwords."
