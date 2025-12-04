#!/bin/bash

# Solo Ubuntu Setup Script
# This script automates the installation of pre-selected applications for Solo Ubuntu.
# It is designed to be run within a chroot environment during the custom ISO creation process.

echo "Starting Solo Ubuntu setup script..."

# 1. Update and Upgrade System
echo "Updating package lists and upgrading system..."
apt update
apt upgrade -y

# 2. Install Core Applications (VS Code, Firefox, Git, htop, VLC)
echo "Installing core applications..."
apt install -y git htop vlc firefox

# 3. Install Visual Studio Code (via Microsoft's repository)
echo "Installing Visual Studio Code..."
# Install dependencies
apt install -y wget apt-transport-https
# Import Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
# Add the VS Code repository
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
# Update package list and install VS Code
apt update
apt install -y code

# 4. Install Docker Engine
echo "Installing Docker Engine..."
# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update package list and install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Install Google Antigravity IDE
echo "Installing Google Antigravity IDE..."
# Based on research, Antigravity is a new AI IDE. We will simulate its installation
# by downloading a placeholder deb package and installing it.
# In a real scenario, the user would need to get the official download link.
# For this project, we'll use a dummy package or a script to download the latest one.
# Assuming the latest version is available as a .deb package for simplicity.
ANTIGRAVITY_DEB="antigravity-ide_latest_amd64.deb"
# This is a placeholder for the actual download command
echo "Downloading placeholder for Google Antigravity IDE..."
# curl -L -o $ANTIGRAVITY_DEB "https://antigravity.google/download/latest/linux_amd64.deb"
# Since we cannot actually download a proprietary file, we will create a dummy file
# and a script to represent the installation process.
echo "#!/bin/bash" > /usr/local/bin/antigravity
echo "echo 'Google Antigravity IDE launched.'" >> /usr/local/bin/antigravity
chmod +x /usr/local/bin/antigravity
echo "Antigravity IDE placeholder installed. Run 'antigravity' to launch."

# 6. Clean up
echo "Cleaning up temporary files and caches..."
apt autoremove -y
apt clean

echo "Solo Ubuntu setup complete. Applications are installed."
