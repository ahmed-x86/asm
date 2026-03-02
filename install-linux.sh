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
    DISTRO=$ID
    # دمج المعرفات المشابهة لسهولة الفحص
    OS_FAMILY=$ID_LIKE
else
    DISTRO="unknown"
fi

case $DISTRO in
    *arch* | *manjaro* | *endeavouros* | *cachyos*)
        echo "Detected Arch-based system ($DISTRO). Installing via pacman..."
        sudo pacman -S --needed --noconfirm nasm mingw-w64-gcc wine binutils ghex
        ;;
    *debian* | *ubuntu* | *mint* | *zorin*)
        echo "Detected Debian/Ubuntu-based system ($DISTRO). Installing via apt..."
        sudo apt update
        sudo apt install -y nasm gcc-mingw-w64 wine binutils ghex
        ;;
    *fedora* | *rhel* | *centos* | *nobara*)
        echo "Detected Fedora-based system ($DISTRO). Installing via dnf..."
        sudo dnf install -y nasm mingw64-gcc wine binutils ghex
        ;;
    *void*)
        echo "Detected Void Linux. Installing via xbps..."
        sudo xbps-install -S nasm cross-x86_64-w64-mingw32-gcc wine binutils ghex
        ;;
    *gentoo*)
        echo "Detected Gentoo Linux. Installing via emerge..."
        echo "Note: This may take time as it compiles from source."
        sudo emerge --ask dev-lang/nasm dev-util/mingw64-toolchain app-emulation/wine-vanilla sys-devel/binutils dev-util/ghex
        ;;
    *)
        echo "Could not auto-detect distribution ($DISTRO)."
        echo "A) Arch | D) Debian | F) Fedora | V) Void | G) Gentoo"
        read -p "Please select your base (A/D/F/V/G): " choice
        case $choice in
            [Aa]* ) sudo pacman -S --needed --noconfirm nasm mingw-w64-gcc wine binutils ghex ;;
            [Dd]* ) sudo apt update && sudo apt install -y nasm gcc-mingw-w64 wine binutils ghex ;;
            [Ff]* ) sudo dnf install -y nasm mingw64-gcc wine binutils ghex ;;
            [Vv]* ) sudo xbps-install -S nasm cross-x86_64-w64-mingw32-gcc wine binutils ghex ;;
            [Gg]* ) sudo emerge --ask dev-lang/nasm dev-util/mingw64-toolchain app-emulation/wine-vanilla sys-devel/binutils dev-util/ghex ;;
        esac
        ;;
esac

echo "------------------------------------------"
echo "Setup finished successfully! Happy Hacking."