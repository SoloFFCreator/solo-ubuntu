#!/usr/bin/env bash
# ==============================================================================
# Project: Solo Ubuntu
# Description: Environment Launcher Script for Termux Host
# Author: Solo Ubuntu Maintainers
# ==============================================================================

set -euo pipefail

readonly ROOTFS_DIR="${HOME}/solo-ubuntu-fs"
readonly C_GREEN='\033[1;32m'
readonly C_YELLOW='\033[1;33m'
readonly C_CYAN='\033[1;36m'
readonly C_RED='\033[1;31m'
readonly C_RESET='\033[0m'

# Verify rootfs exists before attempting to boot
if [ ! -d "${ROOTFS_DIR}" ]; then
    echo -e "${C_RED}[ERROR] Rootfs not found at ${ROOTFS_DIR}.${C_RESET}"
    echo -e "${C_YELLOW}Please run ./install.sh first to set up Solo Ubuntu.${C_RESET}"
    exit 1
fi

echo -e "${C_CYAN}================================================================${C_RESET}"
echo -e "${C_GREEN} Launching Solo Ubuntu...${C_RESET}"
echo -e "${C_CYAN}================================================================${C_RESET}"

# Initialize PulseAudio over TCP to allow sound forwarding from PRoot to Android
if command -v pulseaudio &> /dev/null; then
    pulseaudio --start \
        --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
        --exit-idle-time=-1 2>/dev/null || true
fi

# Export required environment overrides for containerized execution
export PROOT_NO_SECCOMP=1
export PULSE_SERVER=127.0.0.1

# Execute PRoot, binding essential host system directories and sdcard
exec proot \
    --link2symlink \
    -0 \
    -r "${ROOTFS_DIR}" \
    -b /dev \
    -b /proc \
    -b /sys \
    -b "${ROOTFS_DIR}/tmp:/dev/shm" \
    -b /sdcard \
    -b "${HOME}:/home/termux" \
    -w /root \
    /usr/bin/env -i \
        HOME=/root \
        PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin \
        TERM="${TERM}" \
        LANG=C.UTF-8 \
        /bin/bash --login
