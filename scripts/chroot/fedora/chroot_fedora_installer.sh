#!/system/bin/sh

# Colors
green="\033[1;32m"
red="\033[1;31m"
yellow="\033[1;33m"
reset="\033[0m"

info() {
  echo -e "${green}[INFO] $1${reset}"
}

error() {
  echo -e "${red}[ERROR] $1${reset}"
}

warning() {
  echo -e "${yellow}[WARNING] $1${reset}"
}

success() {
  echo -e "${green}[✔] $1${reset}"
}

goodbye() {
  echo -e "${red}[!] Exiting...${reset}"
  exit 1
}

download_file() {
  info "Downloading file..."
  if [ -e "$1/$2" ]; then
    warning "File already exists: $2"
    warning "Skipping download..."
  else
    wget -O "$1/$2" "$3"
    if [ $? -eq 0 ]; then
      success "File downloaded successfully: $2"
    else
      error "Error downloading file: $2. Exiting..."
      goodbye
    fi
  fi
}

FEDORA_URL="https://github.com/termux/proot-distro/releases/download/v3.7.1/fedora-rootfs.tar.xz"
FEDORA_ROOTFS="fedora-rootfs.tar.xz"
INSTALL_DIR="/data/local/tmp/chrootFedora"

mkdir -p $INSTALL_DIR

download_file "$INSTALL_DIR" "$FEDORA_ROOTFS" "$FEDORA_URL"

info "Extracting rootfs..."
cd $INSTALL_DIR
proot --link2symlink tar -xJf $FEDORA_ROOTFS --exclude='dev' || {
  error "Extraction failed"
  goodbye
}

success "Fedora rootfs extracted successfully."

info "Setting up environment..."

echo "/proc /proc proc defaults 0 0" > $INSTALL_DIR/etc/fstab
echo "127.0.0.1 localhost" > $INSTALL_DIR/etc/hosts

success "Fedora chroot installed at $INSTALL_DIR"
