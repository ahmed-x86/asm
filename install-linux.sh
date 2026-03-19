#!/bin/bash


echo "------------------------------------------"
echo "Step 1:download files"
echo "------------------------------------------"


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

# Pre-step: Essential Fix for Alpine Linux
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" == "alpine" ]; then
        echo "Alpine Linux detected. Installing GNU sed for compatibility..."
        sudo apk add --no-cache sed
    fi
fi



echo "------------------------------------------"
echo "Step 2: Detecting Linux Distribution..."
echo "------------------------------------------"



if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    OS_ID=$ID
    OS_LIKE=$ID_LIKE
else
    OS_ID="unknown"
fi


install_uasm_manual() {
    if command -v uasm &> /dev/null; then
        echo "uasm is already installed."
    else
        echo "Downloading and installing uasm binary for Linux..."
        
        curl -fsSL "https://www.terraspace.co.uk/uasm257_linux64.zip" -o uasm_linux.zip
        
        if [ -f "uasm_linux.zip" ]; then
            echo "Extracting uasm..."
            unzip -q uasm_linux.zip -d uasm_temp
            echo "Installing to /usr/local/bin..."
            sudo mv uasm_temp/uasm /usr/local/bin/
            sudo chmod +x /usr/local/bin/uasm
            rm -rf uasm_linux.zip uasm_temp
            echo "uasm installed successfully!"
        else
            echo "Failed to download uasm binary."
        fi
    fi
}

install_packages() {
    case $1 in
        arch)
            echo "Installing for Arch-based system..."
            sudo pacman -S --needed --noconfirm nasm mingw-w64-gcc wine binutils ghex unzip curl
            
            echo "Installing uasm via yay..."
            if command -v yay &> /dev/null; then
                yay -S --needed --noconfirm uasm
            else
                echo "Error: 'yay' is not installed. Please install 'yay' first to be able to install 'uasm' on Arch Linux."
            fi
            ;;
        debian)
            echo "Installing for Debian/Ubuntu-based system..."
            sudo apt update && sudo apt install -y nasm gcc-mingw-w64 wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        fedora)
            echo "Installing for Fedora-based system (Bazzit/Nobara)..."
            sudo dnf install -y nasm mingw64-gcc wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        void)
            echo "Installing for Void Linux..."
            sudo xbps-install -S nasm cross-x86_64-w64-mingw32-gcc wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        gentoo)
            echo "Installing for Gentoo..."
            sudo emerge --ask dev-lang/nasm dev-util/mingw64-toolchain app-emulation/wine-vanilla sys-devel/binutils dev-util/ghex app-arch/unzip net-misc/curl
            install_uasm_manual
            ;;
        solus)
            echo "Installing for Solus..."
            sudo eopkg install nasm mingw-w64 wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        suse)
            echo "Installing for openSUSE..."
            sudo zypper install -y nasm mingw64-gcc wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        alpine)
            echo "Installing for Alpine Linux..."
            sudo apk add nasm mingw-w64-gcc wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        puppy)
            echo "Installing for Puppy Linux (using pkg)..."
            pkg install nasm mingw-w64-gcc wine binutils ghex unzip curl
            install_uasm_manual
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
echo "Step 3: Downloading Irvine Library..."
echo "------------------------------------------"


read -p "Do you want to download the Irvine Library? It is approximately 24 MB in size. (y/n): " download_irvine

if [[ "$download_irvine" =~ ^[Yy]$ ]]; then
    echo "Downloading Irvine.zip..."
    curl -fsSL "http://www.asmirvine.com/gettingStartedVS2019/Irvine.zip" -o irvine.zip
    
    echo "Extracting Irvine library..."
    unzip -q irvine.zip -d irvine
    
    echo "Cleaning up..."
    rm irvine.zip
    echo "Irvine library installed successfully in the 'irvine' directory."
else
    echo "Skipping Irvine library download."
fi

echo "------------------------------------------"
echo "Step 4: Updating launch.json paths to match current directory..."
echo "------------------------------------------"

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
echo "Step 5: Downloading ASM Examples..."
echo "------------------------------------------"

read -p "Do you want to download example Assembly files? (y/n): " download_examples

if [[ "$download_examples" =~ ^[Yy]$ ]]; then
    example_urls=(
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux64_start.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux64_main.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux32_start.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux32_main.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_std_start.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_std_main.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win64_std_start.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win64_std_main.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_irvine_start.asm"
            "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_irvine_main.asm"
        )
        
    for url in "${example_urls[@]}"; do
        file_name=$(basename "$url")
        echo -e " -> Fetching \033[1;36m$file_name\033[0m via curl..."
        curl -fsSL -o "$file_name" "$url"
    done
    echo "Examples downloaded successfully!"
else
    echo "Skipping example files download."
fi

echo "------------------------------------------"
echo "Step 6: Select Your Editor & Install Extensions"
echo "------------------------------------------"
echo "Which editor are you using? (To install Syntax & Error-checking extensions)"
echo "1) VS Code"
echo "2) VS Codium"
echo "3) Cursor"
echo "4) Trae"
echo "5) Windsurf"
echo "6) Google Antigravity"

read -p "Select your editor (1-6): " editor_choice

case $editor_choice in
    1) EDITOR_CMD="code" ;;
    2) EDITOR_CMD="codium" ;;
    3) EDITOR_CMD="cursor" ;;
    4) EDITOR_CMD="trae" ;;
    5) EDITOR_CMD="windsurf" ;;
    6) EDITOR_CMD="antigravity" ;;
    *) EDITOR_CMD="code" ;;
esac

echo -e "Target editor set to: \033[1;32m$EDITOR_CMD\033[0m"


read -p "Do you want to install Assembly extensions (Colors & Error-checking)? (y/n): " install_ext

if [[ "$install_ext" =~ ^[Yy]$ ]]; then
    if command -v $EDITOR_CMD &> /dev/null; then
        echo "Installing extensions for $EDITOR_CMD..."
        
        $EDITOR_CMD --install-extension 13xforever.language-x86-64-assembly --force
        $EDITOR_CMD --install-extension doinkythederp.nasm-language-support --force
        $EDITOR_CMD --install-extension usernamehw.errorlens --force
        echo -e "\033[1;32mExtensions ready! Highlighting and Error-markers active. ✅\033[0m"
    else
        echo -e "\033[1;31mWarning:\033[0m '$EDITOR_CMD' not found in PATH. Skipping extensions."
    fi
fi



echo "------------------------------------------"
echo -e "\033[1;35m🎉 ALL DONE! Your Ultimate Assembly Environment is 100% Ready! 🚀\033[0m"
echo "------------------------------------------"


echo "------------------------------------------"
echo "Setup finished successfully! Happy Hacking."
echo "------------------------------------------"