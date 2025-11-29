#!/bin/bash
set -euo pipefail

# === CONFIG ==========================================================
DISK="${DISK:-/dev/sda}"          # Kohdelevy (VARO – tyhjennetään!)
PART="${PART:-${DISK}1}"
MNT="${MNT:-/mnt/gentoo}"

STAGE_BASE="https://distfiles.gentoo.org/releases/amd64/autobuilds"
STAGE_TXT="latest-stage3-amd64-openrc.txt"
# =====================================================================

echo "[0] HARD WIPE ${DISK} (partition table & first 10MB)"
wipefs -a "${DISK}" || true
dd if=/dev/zero of="${DISK}" bs=1M count=10 status=none || true
partprobe "${DISK}" || true

echo "[1] Create GPT + single ext4 partition"
parted -s "${DISK}" mklabel gpt
parted -s "${DISK}" mkpart primary ext4 1MiB 100%
parted -s "${DISK}" name 1 aigm-root

echo "[2] Create filesystem"
mkfs.ext4 -L AIGM-MINI "${PART}"

echo "[3] Mount root to ${MNT}"
mkdir -p "${MNT}"
mount "${PART}" "${MNT}"

echo "[4] Fetch latest stage3 (official Gentoo mirror only)"
cd /tmp
STAGE_REL=$(wget -qO- "${STAGE_BASE}/${STAGE_TXT}" | awk 'NR==2 {print $1}')
STAGE_URL="${STAGE_BASE}/${STAGE_REL}"
STAGE_FILE="${STAGE_REL##*/}"

echo "    -> ${STAGE_URL}"
wget -q "${STAGE_URL}" -O "${STAGE_FILE}"

echo "[5] Extract stage3 to ${MNT}"
tar xpf "${STAGE_FILE}" -C "${MNT}" --xattrs-include='*.*' --numeric-owner

echo "[6] Copy DNS config"
cp -L /etc/resolv.conf "${MNT}/etc/"

echo "[7] Mount kernel filesystems"
mount --types proc /proc "${MNT}/proc"
mount --rbind /sys "${MNT}/sys"
mount --make-rslave "${MNT}/sys"
mount --rbind /dev "${MNT}/dev"
mount --make-rslave "${MNT}/dev"

echo "[8] Copy post-install script into chroot (if present)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/aigm-mini-post.sh" ]; then
  cp "${SCRIPT_DIR}/aigm-mini-post.sh" "${MNT}/root/aigm-mini-post.sh"
  chmod +x "${MNT}/root/aigm-mini-post.sh"
  echo "    -> /root/aigm-mini-post.sh ready inside chroot."
else
  echo "    [WARN] aigm-mini-post.sh not found next to this script."
  echo "           Copy it manually to ${MNT}/root/ before chroot."
fi

echo
echo "[DONE] Pre-stage complete."
echo "Next steps (from LiveCD):"
echo "  chroot ${MNT} /bin/bash"
echo "  source /etc/profile"
echo "  export PS1=\"(chroot) \$PS1\""
echo "  cd /root && ./aigm-mini-post.sh"
