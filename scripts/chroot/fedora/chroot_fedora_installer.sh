#!/bin/sh

Function to show farewell message

goodbye() { echo -e "\e[1;31m[!] Something went wrong. Exiting...\e[0m" exit 1 }

Function to show progress message

progress() { echo -e "\e[1;36m[+] $1\e[0m" }

Function to show success message

success() { echo -e "\e[1;32m[✓] $1\e[0m" }

Function to download file

download_file() { progress "Downloading file..." if [ -e "$1/$2" ]; then echo -e "\e[1;33m[!] File already exists: $2\e[0m" echo -e "\e[1;33m[!] Skipping download...\e[0m" else wget -O "$1/$2" "$3" if [ $? -eq 0 ]; then success "File downloaded successfully: $2" else echo -e "\e[1;31m[!] Error downloading file: $2. Exiting...\e[0m" goodbye fi fi }

Function to extract file

extract_file() { progress "Extracting file..." if [ -d "$1/fedora-aarch64" ]; then echo -e "\e[1;33m[!] Directory already exists: $1/fedora-aarch64\e[0m" echo -e "\e[1;33m[!] Skipping extraction...\e[0m" else tar -xJpf "$1/fedora-aarch64-pd-v4.24.0.tar.xz" -C "$1" --numeric-owner >/dev/null 2>&1 if [ $? -eq 0 ]; then success "File extracted successfully: $1/fedora-aarch64" else echo -e "\e[1;31m[!] Error extracting file. Exiting...\e[0m" goodbye fi fi }

Function to download and execute script

download_and_execute_script() { progress "Downloading script..." if [ -e "/data/local/tmp/start_fedora.sh" ]; then echo -e "\e[1;33m[!] Script already exists: /data/local/tmp/start_fedora.sh\e[0m" echo -e "\e[1;33m[!] Skipping download...\e[0m" else wget -O "/data/local/tmp/start_fedora.sh" "https://raw.githubusercontent.com/Kenzy-IT/Termux-distro/main/scripts/chroot/fedora/start_fedora.sh" if [ $? -eq 0 ]; then success "Script downloaded successfully: /data/local/tmp/start_fedora.sh" progress "Setting script permissions..." chmod +x "/data/local/tmp/start_fedora.sh" success "Script permissions set" else echo -e "\e[1;31m[!] Error downloading script. Exiting...\e[0m" goodbye fi fi }

Function to configure Fedora chroot environment

configure_fedora_chroot() { progress "Configuring Fedora chroot environment..." FEDORAPATH="/data/local/tmp/chrootFedora"

if [ ! -d "$FEDORAPATH" ]; then
    mkdir -p "$FEDORAPATH"
    if [ $? -eq 0 ]; then
        success "Created directory: $FEDORAPATH"
    else
        echo -e "\e[1;31m[!] Error creating directory: $FEDORAPATH. Exiting...\e[0m"
        goodbye
    fi
fi

mv /data/local/tmp/fedora-aarch64 $FEDORAPATH/fedora-aarch64

busybox mount -o remount,dev,suid /data
busybox mount --bind /dev $FEDORAPATH/fedora-aarch64/dev
busybox mount --bind /sys $FEDORAPATH/fedora-aarch64/sys
busybox mount --bind /proc $FEDORAPATH/fedora-aarch64/proc
busybox mount -t devpts devpts $FEDORAPATH/fedora-aarch64/dev/pts

mkdir $FEDORAPATH/fedora-aarch64/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $FEDORAPATH/fedora-aarch64/dev/shm

mkdir $FEDORAPATH/fedora-aarch64/sdcard
busybox mount --bind /sdcard $FEDORAPATH/fedora-aarch64/sdcard

busybox chroot $FEDORAPATH/fedora-aarch64 /bin/bash -c 'dnf update -y && dnf install nano vim sudo passwd git xterm -y'

if [ $? -eq 0 ]; then
    success "Fedora chroot environment configured"
else
    echo -e "\e[1;31m[!] Error configuring Fedora chroot environment. Exiting...\e[0m"
    goodbye
fi

progress "Setting up user account..."
echo -n "Enter username for Fedora chroot environment: "
read USERNAME

busybox chroot $FEDORAPATH/fedora-aarch64 /bin/bash -c "useradd -m $USERNAME && echo $USERNAME | passwd --stdin $USERNAME"
busybox chroot $FEDORAPATH/fedora-aarch64 /bin/bash -c "echo '$USERNAME ALL=(ALL:ALL) ALL' >> /etc/sudoers"

success "User account set up and sudo permissions configured"

progress "Select a desktop environment to install:"
echo "1. XFCE4"
echo -n "Enter your choice (1): "
read DE_OPTION

case $DE_OPTION in
    1)
        install_xfce4
        ;;
    *)
        echo -e "\e[1;31m[!] Invalid option. Exiting...\e[0m"
        goodbye
        ;;
esac

}

install_xfce4() { progress "Installing XFCE4..." busybox chroot $FEDORAPATH/fedora-aarch64 /bin/bash -c 'dnf install @xfce-desktop-environment dbus-x11 -y' download_startxfce4_script }

download_startxfce4_script() { progress "Downloading startxfce4_chrootFedora.sh script..." wget -O "/data/local/tmp/startxfce4_chrootFedora.sh" "https://raw.githubusercontent.com/Kenzy-IT/Termux-distro/main/scripts/chroot/fedora/startxfce4_chrootFedora.sh" if [ $? -eq 0 ]; then success "startxfce4_chrootFedora.sh script downloaded successfully" chmod +x "/data/local/tmp/startxfce4_chrootFedora.sh" else echo -e "\e[1;31m[!] Error downloading startxfce4_chrootFedora.sh script. Exiting...\e[0m" goodbye fi }

modify_startfile_with_username() { success "Set start_fedora.sh file with user name..." sed -i "s/fedora/$USERNAME/g" "/data/local/tmp/start_fedora.sh" }

main() { if [ "$(whoami)" != "root" ]; then echo -e "\e[1;31m[!] This script must be run as root. Exiting...\e[0m" goodbye else download_dir="/data/local/tmp" download_file "$download_dir" "fedora-aarch64-pd-v4.24.0.tar.xz" "https://github.com/termux/proot-distro/releases/download/v4.24.0/fedora-aarch64-pd-v4.24.0.tar.xz" extract_file "$download_dir" download_and_execute_script configure_fedora_chroot modify_startfile_with_username fi }

echo -e "\e[32m" cat << "EOF"


---

|  \ |/ |  | | |  \ |/| || [__   |  |___ |/    |    || |/ |  | |  |  |
|/ |  \ || | |/ |  | |  | ]  |  | |  \    |___ |  | |  \ || ||  |

EOF echo -e "\e[0m"

main

