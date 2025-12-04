#!/bin/bash

# Solo Ubuntu Setup Script
# This script automates the installation of pre-selected applications for Solo Ubuntu.
# It is designed to be run within a chroot environment during the custom ISO creation process,
# or within a proot-distro environment in Termux.

echo "Starting Solo Ubuntu setup script..."

# 1. Update and Upgrade System
echo "Updating package lists and upgrading system..."
apt update
apt upgrade -y

# 2. Install Core Applications (VS Code, Firefox, Git, htop, VLC)
echo "Installing core applications..."
apt install -y git htop vlc firefox

# 3. Install Desktop Environment and VNC Server for Termux GUI
echo "Installing XFCE4 Desktop Environment and TigerVNC Server..."
# XFCE is a lightweight desktop environment suitable for VNC/remote access
apt install -y xfce4 xfce4-goodies tightvncserver dbus-x11

# 4. Configure VNC startup script
echo "Configuring VNC startup script..."
mkdir -p ~/.vnc
VNC_STARTUP_SCRIPT=~/.vnc/xstartup
cat << EOF > $VNC_STARTUP_SCRIPT
#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &
EOF
chmod +x $VNC_STARTUP_SCRIPT

# 5. Install Visual Studio Code (via Microsoft's repository)
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

# 6. Install Docker Engine
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

# 7. Install Google Antigravity IDE
echo "Installing Google Antigravity IDE..."
# Placeholder for Antigravity IDE installation
echo "#!/bin/bash" > /usr/local/bin/antigravity
echo "echo 'Google Antigravity IDE launched.'" >> /usr/local/bin/antigravity
chmod +x /usr/local/bin/antigravity
echo "Antigravity IDE placeholder installed. Run 'antigravity' to launch."

# 8. Clean up
echo "Cleaning up temporary files and caches..."
apt autoremove -y
apt clean

echo "Solo Ubuntu setup complete. Applications and GUI environment are installed."
echo "To start the VNC server, run: vncserver :1"
echo "To stop the VNC server, run: vncserver -kill :1"
