#!/bin/bash
set -euo pipefail

# === CONFIG ==========================================================
DISK="${DISK:-/dev/sda}"
PART="${PART:-${DISK}1}"
MNT="${MNT:-/mnt/gentoo}"

BASE_URL="http://distfiles.gentoo.org/releases/amd64/autobuilds"
STAGE_TXT="latest-stage3-amd64-openrc.txt"
# NOTE: http käytetään koska minimal-ISO ei aina tue https:ää ilman certtejä.
# =====================================================================

echo "[0] HARD WIPE ${DISK}"
wipefs -a "${DISK}" || true
dd if=/dev/zero of="${DISK}" bs=1M count=10 status=none || true
partprobe "${DISK}" || true

echo "[1] Create GPT + ext4 partition"
parted -s "${DISK}" mklabel gpt
parted -s "${DISK}" mkpart primary ext4 1MiB 100%
parted -s "${DISK}" name 1 aigm-root

echo "[2] Format"
mkfs.ext4 -L AIGM-MINI "${PART}"

echo "[3] Mount"
mkdir -p "${MNT}"
mount "${PART}" "${MNT}"

echo "[4] Fetch stage3 list"
cd /tmp
if ! wget -q "${BASE_URL}/${STAGE_TXT}" -O latest.txt; then
    echo "[ERROR] Could not fetch stage3 list."
    exit 1
fi

STAGE_REL=$(awk 'NR==2 {print $1}' latest.txt)

if [[ -z "$STAGE_REL" ]]; then
    echo "[ERROR] Stage3 filename could not be parsed."
    exit 1
fi

STAGE_URL="${BASE_URL}/${STAGE_REL}"
STAGE_FILE="${STAGE_REL##*/}"

echo "    -> Downloading ${STAGE_URL}"

if ! wget -q "${STAGE_URL}" -O "${STAGE_FILE}"; then
    echo "[ERROR] Could not download stage3 tarball."
    exit 1
fi

echo "[5] Extract stage3"
tar xpvf "${STAGE_FILE}" -C "${MNT}" --xattrs-include='*.*' --numeric-owner

echo "[6] Copy resolv.conf"
cp -L /etc/resolv.conf "${MNT}/etc/"

echo "[7] Mount kernel filesystems"
mount --types proc /proc "${MNT}/proc"
mount --rbind /sys "${MNT}/sys"
mount --make-rslave "${MNT}/sys"
mount --rbind /dev "${MNT}/dev"
mount --make-rslave "${MNT}/dev"

echo "[8] Copy post-script if present"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/aigm-mini-post.sh" ]; then
    cp "${SCRIPT_DIR}/aigm-mini-post.sh" "${MNT}/root/"
    chmod +x "${MNT}/root/aigm-mini-post.sh"
fi

echo "[DONE] Pre-stage complete."
echo "Chroot next:"
echo "    chroot ${MNT} /bin/bash"
echo "    source /etc/profile"
echo "    export PS1=\"(chroot) \$PS1\""
echo "    cd /root && ./aigm-mini-post.sh"
