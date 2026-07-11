#!/usr/bin/env bash
# ==============================================================================
# Project: Solo Ubuntu
# Description: Internal Automated GUI, VNC, and Application Setup Script
# Run this script INSIDE the Solo Ubuntu PRoot environment as root.
# ==============================================================================

set -euo pipefail

# Prevent interactive prompts during apt installations
export DEBIAN_FRONTEND=noninteractive

# ANSI Colors
readonly C_RESET='\033[0m'
readonly C_RED='\033[1;31m'
readonly C_GREEN='\033[1;32m'
readonly C_YELLOW='\033[1;33m'
readonly C_BLUE='\033[1;34m'
readonly C_CYAN='\033[1;36m'

log_info() { echo -e "${C_BLUE}[SOLO-INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SOLO-SUCCESS]${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}[SOLO-WARN]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[SOLO-ERROR]${C_RESET} $1"; >&2; }

# Ensure we are running as root inside the PRoot environment
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root inside Solo Ubuntu."
    exit 1
fi

echo -e "${C_CYAN}================================================================${C_RESET}"
echo -e "${C_GREEN} Solo Ubuntu - Post-Installation GUI & Application Setup${C_RESET}"
echo -e "${C_CYAN}================================================================${C_RESET}\n"

# 1. Base System Updates & Core Utilities
log_info "Updating system repositories and upgrading base packages..."
apt update && apt upgrade -y
log_info "Installing core development and system utilities..."
apt install -y sudo wget curl git nano vim unzip tar build-essential \
    software-properties-common apt-transport-https gpg dbus dbus-x11 \
    x11-xserver-utils xfonts-base xfonts-100dpi xfonts-75dpi

# 2. XFCE4 Desktop Environment & TigerVNC
log_info "Installing XFCE4 Desktop Environment and TigerVNC Server..."
apt install -y xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-common

log_info "Configuring VNC server startup settings..."
mkdir -p /root/.vnc
cat << 'EOF' > /root/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export PULSE_SERVER=127.0.0.1
xrdb $HOME/.Xresources 2>/dev/null
exec startxfce4
EOF
chmod +x /root/.vnc/xstartup

# Set a default VNC configuration to prevent black screens
cat << 'EOF' > /root/.vnc/config
geometry=1280x720
depth=24
dpi=96
EOF

# 3. Media & Streaming Suite Setup
log_info "Installing Streaming and Media playback suite (OBS Studio, VLC, FFMPEG)..."
apt install -y obs-studio vlc ffmpeg pulseaudio-utils

# 4. Microsoft Edge Browser Installation
log_info "Setting up Microsoft Edge repository..."
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft-edge.gpg > /dev/null
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | tee /etc/apt/sources.list.d/microsoft-edge.list
    apt update && apt install -y microsoft-edge-stable
    log_success "Microsoft Edge installed successfully."
else
    log_warn "Microsoft Edge stable official .deb packages are built for x86_64 (amd64) architectures."
    log_warn "Current architecture is ${ARCH}. Installing Chromium as a high-performance drop-in replacement..."
    apt install -y chromium-browser || apt install -y chromium
    # Create an alias/symlink so launching 'microsoft-edge-stable' still opens a browser seamlessly
    ln -sf $(which chromium || which chromium-browser) /usr/local/bin/microsoft-edge-stable
    log_success "Chromium configured as standard web browser fallback."
fi

# 5. Android Studio Setup
log_info "Installing and configuring Android Studio..."
mkdir -p /opt/android-studio
# Download static IDE distribution URL (using stable command line Linux tarball link mirror)
ANDROID_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.3.1.18/android-studio-2023.3.1.18-linux.tar.gz"
log_info "Downloading Android Studio tarball to /tmp..."
if wget --show-progress -qO /tmp/android-studio.tar.gz "${ANDROID_STUDIO_URL}"; then
    log_info "Extracting Android Studio into /opt/android-studio..."
    tar -zxf /tmp/android-studio.tar.gz -C /opt/ --strip-components=1
    rm -f /tmp/android-studio.tar.gz
    
    # Create system symlink
    ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
    
    # Create Desktop Shortcut for XFCE4
    mkdir -p /usr/share/applications
    cat << 'EOF' > /usr/share/applications/android-studio.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=The official Android IDE
Exec=/opt/android-studio/bin/studio.sh %f
Icon=/opt/android-studio/bin/studio.png
Categories=Development;IDE;
Terminal=false
StartupNotify=true
EOF
    chmod +x /usr/share/applications/android-studio.desktop
    log_success "Android Studio configured with desktop launcher and terminal binary."
else
    log_error "Failed to download Android Studio tarball. Skipping installation."
fi

# 6. Google Antigravity IDE (Easter Egg & Wrapper)
log_info "Deploying 'Google Antigravity IDE' module..."
cat << 'EOF' > /usr/local/bin/google-antigravity-ide
#!/usr/bin/env bash
# Google Antigravity IDE - Zero Gravity Coding Wrapper
# Project: Solo Ubuntu

C_GREEN='\033[1;32m'
C_CYAN='\033[1;36m'
C_RESET='\033[0m'

clear
echo -e "${C_GREEN}Initializing Google Antigravity IDE v99.0-ZERO-G...${C_RESET}"
sleep 0.5

# Matrix-style visual easter egg
for i in {1..25}; do
    head -c 80 /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()_+~=' | fold -w 80 | head -n 1
    echo -ne "${C_GREEN}"
    sleep 0.05
done
echo -e "${C_RESET}"

clear
cat << "BANNER"
  ____                   _            _         _   _ 
 / ___|___   ___   __ _ | | ___      / \   _ __ | |_(_)
| |   / _ \ / _ \ / _` || |/ _ \    / _ \ | '_ \| __| |
| |__| (_) | (_) | (_| || |  __/   / ___ \| | | | |_| |
 \____\___/ \___/ \__, ||_|\___|  /_/   \_\_| |_|\__|_|
                  |___/                                
       [ ZERO GRAVITY CODE EXECUTION ENGINE ENGAGED ]
BANNER
echo -e "${C_CYAN}================================================================${C_RESET}"
echo -e "${C_GREEN} Welcome, Developer. Gravity restrictions have been disabled.${C_RESET}"
echo -e "${C_CYAN}================================================================${C_RESET}\n"
sleep 1.5

# Fallback to visual editor if X11 is running, otherwise drop into Nano
if [ -n "${DISPLAY:-}" ] && command -v code &> /dev/null; then
    exec code "$@"
else
    exec nano "$@"
fi
EOF
chmod +x /usr/local/bin/google-antigravity-ide
log_success "Google Antigravity IDE command registered globally: google-antigravity-ide"

# 7. Final Clean Up
log_info "Cleaning up apt cache to save storage..."
apt autoremove -y && apt clean

echo -e "\n${C_GREEN}================================================================${C_RESET}"
echo -e "${C_GREEN} Solo Ubuntu GUI & Application setup complete!${C_RESET}"
echo -e "${C_CYAN} To start your desktop interface, run the following command:${C_RESET}"
echo -e "   ${C_YELLOW}vncserver -localhost no :1${C_RESET}"
echo -e "${C_CYAN} Then open your VNC client and connect to: ${C_YELLOW}127.0.0.1:5901${C_RESET}"
echo -e "${C_GREEN}================================================================${C_RESET}\n"
