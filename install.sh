#!/bin/bash
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Detect OS
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -qE "debian|ubuntu" /etc/os-release; then
        OS="debian"
    elif grep -q "arch" /etc/os-release; then
        OS="arch"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif grep -q "WSL" /proc/version &>/dev/null; then
    OS="wsl"
fi

# Ensure sudo is installed (for CI or minimal environments)
if ! command_exists sudo; then
    echo "sudo is not installed. Installing sudo..."
    case "$OS" in
        "debian" | "wsl")
            su -c "apt update && apt install sudo -y"
            ;;
        "arch")
            su -c "pacman -Sy --noconfirm sudo"
            ;;
        *)
            echo "Unsupported OS for automatic sudo installation. Please install manually."
            exit 1
            ;;
    esac
fi

# Ensure Git is installed
if ! command_exists git; then
    echo "Git is not installed. Installing Git..."
    case "$OS" in
        "debian" | "wsl")
            sudo apt update && sudo apt install -y git
            ;;
        "arch")
            sudo pacman -Sy --noconfirm git
            ;;
        "macos")
            brew install git
            ;;
        *)
            echo "Unsupported OS. Please install Git manually."
            exit 1
            ;;
    esac
fi

# Ensure script is run from repo root
if [ ! -f "install.sh" ]; then
    echo "run this script from the repository root"
    exit 1
fi


# Check if OpenCV is installed
if pkg-config --exists opencv4 sdl2; then
    echo "OpenCV is already installed."
    exit 0
else
    echo "OpenCV not found. Installing dependencies..."
fi

# Install dependencies based on OS
case "$OS" in
    "debian" | "wsl")
        echo "🔹 Detected Debian/Ubuntu or WSL"
        
        # Install sudo if not available (for containers)
        if ! command_exists sudo; then
            su -c "apt update && apt install sudo -y"
        fi
        
        export DEBIAN_FRONTEND=noninteractive
        sudo ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
        sudo apt-get install -y tzdata
        sudo dpkg-reconfigure --frontend noninteractive tzdata

        # Install pkg-config and OpenCV dependencies
        sudo apt update -y
        sudo apt install -y pkg-config build-essential make g++ git libopencv-dev libsdl2-2.0-0 libsdl2-image-dev libsdl2-dev
        ;;
    "arch")
        echo "🔹 Detected Arch Linux"
        sudo pacman -Sy --noconfirm base-devel opencv hdf5 glew vtk fmt sdl2 pkg-config
        ;;
    "macos")
        echo "🔹 Detected macOS"
        if ! command_exists brew; then
            echo "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install git cmake opencv sdl2
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac

echo "Installation complete!"
