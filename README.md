# 🚀 Solo Ubuntu

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Termux-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

**Solo Ubuntu** is a powerful, heavily modified, and upgraded fork of the original `ubuntu-on-android` project. It transforms your Android device into a full-fledged portable Linux workstation running Ubuntu inside Termux via PRoot—no root access required.

Unlike standard CLI-only implementations, **Solo Ubuntu** comes pre-configured with a full **XFCE4 Graphical Desktop Environment**, a **TigerVNC server** for remote or local graphical access, a complete media streaming suite, and custom development environments.

---

## ✨ Key Features

* **Desktop Environment Out-of-the-Box:** Automated installation of the lightweight, highly customizable XFCE4 desktop environment.
* **Graphical Access via VNC:** Integrated TigerVNC standalone server configuration with D-Bus and PulseAudio bindings for seamless audio and video output.
* **Microsoft Edge Browser:** Pre-configured Microsoft repository integration for web browsing.
* **Android Studio Ready:** Automated extraction and desktop launcher creation for the latest Android Studio Linux builds in `/opt/`.
* **Content Creator & Streaming Suite:** Pre-installed streaming tools including **OBS Studio**, **VLC Media Player**, and **FFMPEG**.
* **Google Antigravity IDE:** Includes a custom terminal-based matrix easter egg and IDE wrapper for high-focus coding sessions.
* **Seamless Storage Integration:** Auto-binds your Android `/sdcard` storage directly into the Ubuntu file system for painless file sharing.

---

## 📋 Prerequisites

1. **Android Device:** Running Android 8.0 (Oreo) or higher (ARM64 recommended).
2. **Termux:** You **must** install Termux from [F-Droid](https://f-droid.org/packages/com.termux/). *Do not use the Google Play Store version, as it is deprecated and unsupported.*
3. **Storage Space:** At least **8 GB to 10 GB** of free internal storage to accommodate the rootfs, GUI environment, Android Studio, and streaming tools.
4. **VNC Viewer:** A VNC client app installed on your Android device (e.g., *RealVNC Viewer*, *bVNC*, or *AVNC*) or a PC on the same local network.

---

## ⚡ Installation Guide

### Step 1: Prepare Termux and Clone the Repository
Open Termux on your Android device and run the following commands to update your system, install Git, and download the Solo Ubuntu installer:

```bash
pkg update && pkg upgrade -y
pkg install git curl wget proot -y
git clone [https://github.com/YourUsername/Solo-Ubuntu.git](https://github.com/YourUsername/Solo-Ubuntu.git)
cd Solo-Ubuntu
chmod +x *.sh
``` 
Step 2: Run the Main Installer
Execute the bootstrap script. This will request Android storage permissions, download the Ubuntu rootfs, and build the PRoot environment:
```
./install.sh
```
Step 3: Start Solo Ubuntu
Once the bootstrap completes, drop into your new Ubuntu terminal environment:
./start-solo.sh
Step 4: Install GUI and Applications
Inside the Solo Ubuntu terminal (you will see a root@localhost:~# prompt), run the automated application setup script:

```
./setup-gui-apps.sh
```
Note: This step downloads and compiles several gigabytes of desktop software. Grab a coffee; it may take 15–30 minutes depending on your internet connection and device speed.
🖥️ Connecting to the Graphical Desktop (VNC)
Once ./setup-gui-apps.sh completes, start your graphical
display server from inside Solo Ubuntu:
```
vncserver -localhost no :1
```

(The first time you run this, you will be prompted to create a VNC password. Choose an 8-character password. You can answer "No" to creating a view-only password.)
Connecting via Android App (Localhost)
Open your VNC Viewer app (e.g., RealVNC Viewer).
Create a new connection with the Address: 127.0.0.1:5901 (or localhost:5901).
Name it Solo Ubuntu Desktop.
Connect and enter the VNC password you set earlier.
Killing the VNC Server
To stop the desktop session and free up RAM, run:
```
vncserver -kill :1
```
Application Showcase & Custom Commands
Launch Android Studio: Search for Android Studio in your XFCE4 applications menu under "Development", or launch it from the terminal using:
```
android-studio &
```
Launch Microsoft Edge: Find it in the XFCE4 "Internet" menu or type:
```
microsoft-edge-stable &
 ```
Google Antigravity IDE: Experience zero-gravity coding! Launch our custom easter egg IDE wrapper from the terminal:
```
google-antigravity-ide /path/to/your/file.py
```
OBS Studio & VLC: Fully accessible via the XFCE4 "Multimedia" menu for recording your PRoot screen or streaming media.



🛠️ Troubleshooting & Notes
Architecture Limitations (ARM64 vs. x86_64): Most modern Android devices use ARM64 processors. While applications like VLC, OBS, and XFCE4 compile natively for ARM64, pre-compiled proprietary x86_64 binaries (like official Microsoft Edge .deb packages or specific Android Studio x86 emulators) may require translation layers like box86/box64 or will fall back to Chromium-based alternatives automatically during setup.
Audio Output: Solo Ubuntu routes audio through Termux's PulseAudio server. If audio fails, ensure Termux is running in the background and execute pulseaudio --start from the native Termux session before launching ./start-solo.sh.
📄 License & Acknowledgments
This project is licensed under the MIT License.
Originally inspired by and forked from ubuntu-on-android by RandomCoderOrg.
Rebranded, optimized, and maintained by the Solo Ubuntu Team.
