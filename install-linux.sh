#!/bin/bash

mkdir -p .vscode

files=("c_cpp_properties.json" "launch.json" "settings.json" "tasks.json")
LOCAL_DIR="install-linux"

echo "Step 1: Checking for local configurations..."

if [ -d "$LOCAL_DIR" ]; then
    echo "Found local directory: $LOCAL_DIR. Copying files..."
    for file in "${files[@]}"; do
        if [ -f "$LOCAL_DIR/$file" ]; then
            cp "$LOCAL_DIR/$file" ".vscode/$file"
            echo "Copied $file from local storage."
        else
            echo "Warning: $file not found in $LOCAL_DIR."
        fi
    done
else
    echo "Local directory not found. Starting download from GitHub..."
    for file in "${files[@]}"; do
        URL="https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux/$file"
        curl -fsSL "$URL" -o ".vscode/$file"
        echo "Downloaded $file"
    done
fi

echo "------------------------------------------"
echo "VS Code configuration complete!"
echo "------------------------------------------"

echo "Step 2: Detecting Linux Distribution..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    OS_ID=$ID
    OS_LIKE=$ID_LIKE
else
    OS_ID="unknown"
fi


install_packages() {
    case $1 in
        arch)
            echo "Installing for Arch-based system..."
            sudo pacman -S --needed --noconfirm nasm mingw-w64-gcc wine binutils ghex
            ;;
        debian)
            echo "Installing for Debian/Ubuntu-based system..."
            sudo apt update && sudo apt install -y nasm gcc-mingw-w64 wine binutils ghex
            ;;
        fedora)
            echo "Installing for Fedora-based system (Bazzit/Nobara)..."
            sudo dnf install -y nasm mingw64-gcc wine binutils ghex
            ;;
        void)
            echo "Installing for Void Linux..."
            sudo xbps-install -S nasm cross-x86_64-w64-mingw32-gcc wine binutils ghex
            ;;
        gentoo)
            echo "Installing for Gentoo..."
            sudo emerge --ask dev-lang/nasm dev-util/mingw64-toolchain app-emulation/wine-vanilla sys-devel/binutils dev-util/ghex
            ;;
        solus)
            echo "Installing for Solus..."
            sudo eopkg install nasm mingw-w64 wine binutils ghex
            ;;
        suse)
            echo "Installing for openSUSE..."
            sudo zypper install -y nasm mingw64-gcc wine binutils ghex
            ;;
        alpine)
            echo "Installing for Alpine Linux..."
            sudo apk add nasm mingw-w64-gcc wine binutils ghex
            ;;
        puppy)
            echo "Installing for Puppy Linux (using pkg)..."
            pkg install nasm mingw-w64-gcc wine binutils ghex
            ;;
    esac
}


if [[ "$OS_ID" =~ (arch|manjaro|endeavouros|cachyos) ]] || [[ "$OS_LIKE" == *"arch"* ]]; then
    install_packages arch
elif [[ "$OS_ID" =~ (debian|ubuntu|mint|zorin|peppermint|kali|parrot) ]] || [[ "$OS_LIKE" == *"debian"* ]]; then
    install_packages debian
elif [[ "$OS_ID" =~ (fedora|nobara|bazzit|rhel|centos) ]] || [[ "$OS_LIKE" == *"fedora"* ]]; then
    install_packages fedora
elif [[ "$OS_ID" == "void" ]]; then
    install_packages void
elif [[ "$OS_ID" == "gentoo" ]]; then
    install_packages gentoo
elif [[ "$OS_ID" == "solus" ]]; then
    install_packages solus
elif [[ "$OS_ID" =~ (suse|opensuse) ]]; then
    install_packages suse
elif [[ "$OS_ID" == "alpine" ]]; then
    install_packages alpine
elif [[ "$OS_ID" == "pappoos" ]] || [[ "$OS_NAME" == *"Puppy"* ]]; then
    install_packages puppy
else
    echo "Could not auto-detect distribution ($OS_ID)."
    echo "1) Arch  2) Debian  3) Fedora  4) Void  5) Gentoo  6) Solus  7) openSUSE  8) Alpine"
    read -p "Select your base (1-8): " choice
    case $choice in
        1) install_packages arch ;;
        2) install_packages debian ;;
        3) install_packages fedora ;;
        4) install_packages void ;;
        5) install_packages gentoo ;;
        6) install_packages solus ;;
        7) install_packages suse ;;
        8) install_packages alpine ;;
    esac
fi

echo "------------------------------------------"
echo "install packages complete"
echo "------------------------------------------"


echo "Step 3: Updating launch.json paths to match current directory..."


CURRENT_DIR=$(pwd)
LAUNCH_FILE=".vscode/launch.json"


if [ -f "$LAUNCH_FILE" ]; then
    
    sed -i "s|\"cwd\": \"/mnt/data/github_repos/asm\"|\"cwd\": \"$CURRENT_DIR\"|g" "$LAUNCH_FILE"
    
    
    sed -i "s|\"program\": \"/mnt/data/github_repos/asm/build/Debug/outDebug\"|\"program\": \"$CURRENT_DIR/build/Debug/outDebug\"|g" "$LAUNCH_FILE"
    
    echo "Successfully updated paths in $LAUNCH_FILE to $CURRENT_DIR"
else
    echo "Warning: $LAUNCH_FILE not found. Skipping path update."
fi

echo "------------------------------------------"
echo "Setup finished successfully! Happy Hacking."
echo "------------------------------------------"
