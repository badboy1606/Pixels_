#!/bin/bash
set -e

REPO_URL="https://github.com/SRA-VJTI/Pixels.git"
REPO_NAME="Pixels"

command_exists() {
    command -v "$1" &>/dev/null
}
#detect os 
OS=""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    . /etc/os-release
    if [[ "$ID_LIKE" == *"debian"* ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
        OS="debian"
    elif [[ "$ID_LIKE" == *"arch"* ]] || [[ "$ID" == "arch" ]]; then
        OS="arch"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif grep -q "WSL" /proc/version &>/dev/null; then
    OS="wsl"
fi



if ! command_exists sudo; then
    case "$OS" in
        debian|wsl) su -c "apt update && apt install sudo -y" ;;
        arch) su -c "pacman -Sy --noconfirm sudo" ;;
        *) echo "Install sudo manually"; exit 1 ;;
    esac
fi

# Ensure Git is installed
if ! command_exists git; then
    echo "Installing git..."
    case "$OS" in
        debian|wsl) sudo apt update && sudo apt install -y git ;;
        arch) sudo pacman -Sy --noconfirm git ;;
        macos) brew install git ;;
    esac
fi

#checking if repo is present or not 
if [ -f "Makefile" ]; then
    echo "Running inside Pixels repository"
else
    echo "Pixels repo not found, cloning"
    git clone "$REPO_URL"
    cd "$REPO_NAME"
fi

#make installation
if ! command_exists make; then
    echo "Installing make..."
    case "$OS" in
        debian|wsl) sudo apt install -y make ;;
        arch) sudo pacman -Sy --noconfirm make ;;
        macos) brew install make ;;
    esac
fi

echo "Installing dependencies via make"
make install

echo "Setup complete"
