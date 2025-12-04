#!/bin/bash

# Solo Ubuntu Termux Installer
# This script automates the setup of a Solo Ubuntu environment on Android using Termux and proot-distro.

echo "Starting Solo Ubuntu installation for Termux..."

# 1. Update Termux packages
echo "Updating Termux packages..."
pkg update -y && pkg upgrade -y

# 2. Install required packages (proot-distro and git)
echo "Installing proot-distro and git..."
pkg install proot-distro git -y

# 3. Install Ubuntu using proot-distro
echo "Installing Ubuntu via proot-distro. This may take some time..."
proot-distro install ubuntu

# 4. Clone the Solo Ubuntu repository
if [ -d "/home/ubuntu/solo-ubuntu" ]; then
    echo "Solo Ubuntu repository already exists. Skipping clone."
else
    echo "Cloning the Solo Ubuntu repository..."
    git clone https://github.com/SoloFFCreator/solo-ubuntu.git /home/ubuntu/solo-ubuntu
fi

# 5. Copy the setup script into the Ubuntu proot environment
echo "Copying the setup script into the Ubuntu environment..."
cp /home/ubuntu/solo-ubuntu/solo-ubuntu-setup.sh ~/.proot-distro/installed-rootfs/ubuntu/root/

# 6. Final instructions
echo ""
echo "---------------------------------------------------"
echo "Installation of base Ubuntu is complete."
echo "To log in to your new Ubuntu environment, use the following command:"
echo ""
echo "    proot-distro login ubuntu"
echo ""
echo "Once you are logged in, run the following command to install all the applications:"
echo ""
echo "    bash /root/solo-ubuntu-setup.sh"
echo "---------------------------------------------------"
