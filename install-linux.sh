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
            echo "Warning: $file not found in $LOCAL_DIR, will try to download later."
        fi
    done
else
    echo "Local directory not found. Starting download..."
    
    
    for file in "${files[@]}"; do
        URL="https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux/$file"
        curl -fsSL "$URL" -o ".vscode/$file"
        
        if [ $? -eq 0 ]; then
            echo "Successfully downloaded $file"
        else
            echo "Failed to download $file"
        fi
    done
fi

echo "VS Code configuration complete!"