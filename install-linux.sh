#!/bin/bash


mkdir -p .vscode


files=("c_cpp_properties.json" "launch.json" "settings.json" "tasks.json")
LOCAL_DIR="install-linux"

echo "Checking for local configurations..."


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
    echo "Local directory not found. Starting download..."
    for file in "${files[@]}"; do
        URL="https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux/$file"
        curl -fsSL "$URL" -o ".vscode/$file"
    done
fi

echo "------------------------------------------"
echo "VS Code configuration complete!"
echo "------------------------------------------"


echo "Which Linux distribution are you using?"
echo "A) Arch based"
echo "D) Debian/Ubuntu based"
echo "F) Fedora based"
read -p "Please enter your choice (A/D/F): " choice

case $choice in
    [Aa]* )
        echo "Installing dependencies for Arch Linux..."
        
        sudo pacman -S --needed --noconfirm nasm mingw-w64-gcc wine binutils ghex
        ;;
    [Dd]* )
        echo "Installing dependencies for Debian/Ubuntu..."
        sudo apt update
        sudo apt install -y nasm gcc-mingw-w64 wine binutils ghex
        ;;
    [Ff]* )
        echo "Installing dependencies for Fedora..."
        sudo dnf install -y nasm mingw64-gcc wine binutils ghex
        ;;
    * )
        echo "Invalid choice. Skipping dependency installation."
        ;;
esac

echo "Setup finished successfully!"