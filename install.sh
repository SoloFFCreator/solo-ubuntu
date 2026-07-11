

### `install.sh`

```bash
#!/usr/bin/env bash
# ==============================================================================
# Project: Solo Ubuntu
# Description: Main Bootstrap & Rootfs Installer for Termux
# Author: Solo Ubuntu Maintainers
# ==============================================================================

# Fail fast on errors, undefined variables, and pipe failures
set -euo pipefail

# ANSI Color Codes for Modern Terminal UI
readonly C_RESET='\033[0m'
readonly C_RED='\033[1;31m'
readonly C_GREEN='\033[1;32m'
readonly C_YELLOW='\033[1;33m'
readonly C_BLUE='\033[1;34m'
readonly C_CYAN='\033[1;36m'

# Project Constants
readonly PROJECT_NAME="Solo Ubuntu"
readonly ROOTFS_DIR="${HOME}/solo-ubuntu-fs"
readonly UBUNTU_VERSION="22.04"
readonly UBUNTU_BASE_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/${UBUNTU_VERSION}/release"

log_info() { echo -e "${C_BLUE}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}[WARNING]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $1"; >&2; }

# Clear screen and display branding header
clear
cat << "EOF"
  ____        _          _   _ _               _         
 / ___|  ___ | | ___    | | | | |__ _   _ _ __| |_ _   _ 
 \___ \ / _ \| |/ _ \   | | | | '_ \ | | | '__| __| | | |
  ___) | (_) | | (_) |  | |_| | |_) | |_| | |  | |_| |_| |
 |____/ \___/|_|\___/    \___/|_.__/ \__,_|_|   \__|\__,_|
                                                          
EOF
echo -e "${C_CYAN}================================================================${C_RESET}"
echo -e "${C_GREEN} Welcome to the ${PROJECT_NAME} Installer!${C_RESET}"
echo -e "${C_CYAN}================================================================${C_RESET}\n"

# Verify execution environment
if [ -z "${PREFIX:-}" ] || [ -z "${TERMUX_VERSION:-}" ]; then
    log_warn "This script is designed to run inside Termux on Android."
    read -p "Are you sure you want to continue outside Termux? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Installation aborted by user."
        exit 1
    fi
else
    log_info "Termux environment detected. Requesting storage permissions..."
    termux-setup-storage sleep 2
fi

# Update Termux packages and install required dependencies
log_info "Updating Termux base repositories and dependencies..."
pkg update -y && pkg upgrade -y
pkg install -y proot wget curl tar pulseaudio git ncurses-utils

# Detect System Architecture
ARCH=$(uname -m)
log_info "Detected system architecture: ${C_YELLOW}${ARCH}${C_RESET}"

case "${ARCH}" in
    aarch64|arm64)
        ROOTFS_TAR="ubuntu-base-${UBUNTU_VERSION}.5-base-arm64.tar.gz"
        ;;
    armv7l|armhf)
        ROOTFS_TAR="ubuntu-base-${UBUNTU_VERSION}.5-base-armhf.tar.gz"
        ;;
    x86_64|amd64)
        ROOTFS_TAR="ubuntu-base-${UBUNTU_VERSION}.5-base-amd64.tar.gz"
        ;;
    *)
        log_error "Unsupported architecture: ${ARCH}. Solo Ubuntu supports arm64, armhf, and amd64."
        exit 1
        ;;
esac

# Create rootfs directory
if [ -d "${ROOTFS_DIR}" ]; then
    log_warn "Existing Solo Ubuntu installation detected at ${ROOTFS_DIR}."
    read -p "Do you want to wipe it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Removing old rootfs..."
        rm -rf "${ROOTFS_DIR}"
    else
        log_info "Proceeding with existing filesystem..."
    fi
fi

mkdir -p "${ROOTFS_DIR}"
cd "${ROOTFS_DIR}"

# Download Ubuntu Base Rootfs if not present
if [ ! -f "${ROOTFS_TAR}" ]; then
    log_info "Downloading Ubuntu ${UBUNTU_VERSION} Base Rootfs (${ROOTFS_TAR})..."
    DOWNLOAD_URL="${UBUNTU_BASE_URL}/${ROOTFS_TAR}"
    if ! wget --show-progress -qO "${ROOTFS_TAR}" "${DOWNLOAD_URL}"; then
        log_error "Failed to download rootfs from ${DOWNLOAD_URL}."
        log_info "Attempting fallback mirror fetch..."
        # Fallback to general arm64 release filename if minor subversion differs
        wget --show-progress -qO "${ROOTFS_TAR}" "https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-${ARCH/aarch64/arm64}.tar.gz" || {
            log_error "Fallback download failed. Please check your internet connection."
            exit 1
        }
    fi
    log_success "Rootfs archive downloaded successfully."
fi

# Extract Rootfs
log_info "Extracting Ubuntu filesystem (this may take a few minutes)..."
proot --link2symlink tar -zxf "${ROOTFS_TAR}" --exclude='dev' || tar -zxf "${ROOTFS_TAR}"
rm -f "${ROOTFS_TAR}"
log_success "Filesystem extracted to ${ROOTFS_DIR}."

# Configure DNS Resolver inside PRoot
log_info "Configuring network DNS resolvers..."
echo "nameserver 8.8.8.8" > "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 1.1.1.1" >> "${ROOTFS_DIR}/etc/resolv.conf"
echo "127.0.0.1 localhost" > "${ROOTFS_DIR}/etc/hosts"

# Copy internal setup script into the newly created rootfs
if [ -f "${OLDPWD}/setup-gui-apps.sh" ]; then
    log_info "Injecting setup-gui-apps.sh into Solo Ubuntu environment..."
    cp "${OLDPWD}/setup-gui-apps.sh" "${ROOTFS_DIR}/root/"
    chmod +x "${ROOTFS_DIR}/root/setup-gui-apps.sh"
else
    log_warn "setup-gui-apps.sh not found in current working directory. You will need to copy it manually."
fi

# Create launcher script
log_info "Generating start-solo.sh launcher..."
cat << 'EOF' > "${OLDPWD}/start-solo.sh"
#!/usr/bin/env bash
# Solo Ubuntu Launcher
set -e

readonly ROOTFS_DIR="${HOME}/solo-ubuntu-fs"
readonly C_GREEN='\033[1;32m'
readonly C_CYAN='\033[1;36m'
readonly C_RESET='\033[0m'

# Start PulseAudio over network tcp for sound bridging
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 2>/dev/null || true

echo -e "${C_CYAN}Starting Solo Ubuntu Environment...${C_RESET}"
echo -e "${C_GREEN}Tip: Run ./setup-gui-apps.sh inside to configure your desktop!${C_RESET}"

# Export environment configurations for PRoot
export PROOT_NO_SECCOMP=1
export PULSE_SERVER=127.0.0.1

# Execute PRoot environment
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
EOF

chmod +x "${OLDPWD}/start-solo.sh"
log_success "Launcher generated: start-solo.sh"

echo -e "\n${C_GREEN}================================================================${C_RESET}"
echo -e "${C_GREEN} Solo Ubuntu bootstrap completed successfully!${C_RESET}"
echo -e "${C_CYAN} To enter your new environment, run:${C_RESET}"
echo -e "   ${C_YELLOW}./start-solo.sh${C_RESET}"
echo -e "${C_GREEN}================================================================${C_RESET}\n"
