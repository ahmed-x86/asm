#!/bin/bash

set -e

SUDO_CMD=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo &> /dev/null; then
        SUDO_CMD="sudo"
    else
        echo -e "\033[1;31mError: You are not root and 'sudo' is not installed. Please run as root.\033[0m"
        exit 1
    fi
fi

echo "------------------------------------------"
echo "Step 0: Checking Internet Connectivity..."
echo "------------------------------------------"


if ! ping -c 1 -W 3 8.8.8.8 &> /dev/null; then
    echo -e "\033[1;31mError: No internet connection detected.\033[0m"
    echo -e "\033[1;33mTo ensure no errors occur because there is no internet currently, please run the script again when internet is available.\033[0m"
    exit 1
fi


echo "Testing connection speed/stability..."
AVG_PING=$(ping -c 3 8.8.8.8 2>/dev/null | tail -1 | awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)


if [[ "$AVG_PING" =~ ^[0-9]+$ ]] && [ "$AVG_PING" -gt 200 ]; then
    echo -e "\033[1;33mIt seems the internet speed is slow (High Latency: ${AVG_PING}ms). Errors may occur during downloads.\033[0m"
    
    set +e # Turn off exit-on-error temporarily for the prompt
    read -p "Do you want to continue? (y/n): " continue_script
    set -e
    
    if [[ ! "$continue_script" =~ ^[Yy]$ ]]; then
        echo -e "\033[1;36mNo worries! Better luck next time. Catch you later when the connection is more stable! 🚀\033[0m"
        exit 0
    else
        echo -e "\033[1;32mAlright, let's proceed with caution!\033[0m"
    fi
else
    echo -e "\033[1;32mInternet connection looks good! ✅\033[0m"
fi


echo "------------------------------------------"
echo "Step 1: Detecting Linux Distribution & Installing Packages..."
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
        
        echo "Extracting uasm..."
        unzip -q uasm_linux.zip -d uasm_temp
        echo "Installing to /usr/local/bin..."
        $SUDO_CMD mv uasm_temp/uasm /usr/local/bin/
        $SUDO_CMD chmod +x /usr/local/bin/uasm
        rm -rf uasm_linux.zip uasm_temp
        echo "uasm installed successfully!"
    fi
}

install_packages() {
    case $1 in
        arch)
            echo "Installing for Arch-based system..."
            $SUDO_CMD pacman -S --needed --noconfirm nasm mingw-w64-gcc wine binutils ghex unzip curl
            
            echo "Installing uasm via yay..."
            if command -v yay &> /dev/null; then
                yay -S --needed --noconfirm uasm
            else
                echo -e "\033[1;33mWarning: 'yay' is not installed. Installing uasm manually...\033[0m"
                install_uasm_manual
            fi
            ;;
        debian)
            echo "Installing for Debian/Ubuntu-based system..."
            $SUDO_CMD apt update && $SUDO_CMD apt install -y nasm gcc-mingw-w64 wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        fedora)
            echo "Installing for Fedora-based system (Bazzit/Nobara)..."
            $SUDO_CMD dnf install -y nasm mingw64-gcc wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        void)
            echo "Installing for Void Linux..."
            $SUDO_CMD xbps-install -S nasm cross-x86_64-w64-mingw32-gcc wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        gentoo)
            echo "Installing for Gentoo..."
            $SUDO_CMD emerge --ask dev-lang/nasm dev-util/mingw64-toolchain app-emulation/wine-vanilla sys-devel/binutils dev-util/ghex app-arch/unzip net-misc/curl
            install_uasm_manual
            ;;
        solus)
            echo "Installing for Solus..."
            $SUDO_CMD eopkg install nasm mingw-w64 wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        suse)
            echo "Installing for openSUSE..."
            $SUDO_CMD zypper install -y nasm mingw64-gcc wine binutils ghex unzip curl
            install_uasm_manual
            ;;
        alpine)
            echo "Installing for Alpine Linux..."
            $SUDO_CMD apk add --no-cache nasm mingw-w64-gcc wine binutils ghex unzip curl sed
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
elif [[ "$OS_ID" == "puppy" ]] || [[ "$OS_NAME" == *"Puppy"* ]]; then
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
echo "Step 2: Downloading VS Code configs..."
echo "------------------------------------------"

mkdir -p .vscode
files=("c_cpp_properties.json" "launch.json" "settings.json" "tasks.json")
LOCAL_DIR="install-linux"

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
echo "Step 3: Downloading Irvine Library..."
echo "------------------------------------------"


set +e 
read -p "Do you want to download the Irvine Library? It is approximately 24 MB in size. (y/n): " download_irvine
set -e

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

set +e
read -p "Do you want to download example Assembly files? (y/n): " download_examples
set -e

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
echo "Step 6: Smart Editor Detection & Extension Setup"
echo "------------------------------------------"

echo "Scanning system for installed code editors..."

EDITORS=(
    "VS Code:code:visual-studio-code-bin:code:com.visualstudio.code"
    "VS Codium:codium:vscodium-bin:codium:com.vscodium.codium"
    "Cursor:cursor:cursor-bin:cursor:"
    "Trae:trae:trae-bin:trae:"
    "Windsurf:windsurf:windsurf-bin:windsurf:"
)

DETECTED_EDITOR=""
FOUND=false


for editor_data in "${EDITORS[@]}"; do
    IFS=':' read -r e_name e_cmd e_pkg e_deb e_flatpak <<< "$editor_data"
    
    if command -v "$e_cmd" &> /dev/null; then
        echo -e "\033[1;32mAuto-detected $e_name installed via Package Manager! ✅\033[0m"
        EDITOR_CMD="$e_cmd"
        DETECTED_EDITOR="$e_name"
        FOUND=true
        break
    elif command -v snap &> /dev/null && snap list 2>/dev/null | grep -q "^$e_cmd"; then
        echo -e "\033[1;32mAuto-detected $e_name installed via Snap! ✅\033[0m"
        EDITOR_CMD="snap run $e_cmd"
        DETECTED_EDITOR="$e_name"
        FOUND=true
        break
    elif [[ -n "$e_flatpak" ]] && command -v flatpak &> /dev/null && flatpak list 2>/dev/null | grep -q "$e_flatpak"; then
        echo -e "\033[1;32mAuto-detected $e_name installed via Flatpak! ✅\033[0m"
        EDITOR_CMD="flatpak run $e_flatpak"
        DETECTED_EDITOR="$e_name"
        FOUND=true
        break
    fi
done


if [ "$FOUND" = false ]; then
    echo -e "\033[1;33mCould not automatically detect an installed editor.\033[0m"
    echo "Which editor are you using?"
    echo "1) VS Code"
    echo "2) VS Codium"
    echo "3) Cursor"
    echo "4) Trae"
    echo "5) Windsurf"
    echo "6) Google Antigravity"

    set +e
    read -p "Select your editor (1-6): " editor_choice
    set -e

    case $editor_choice in
        1) EDITOR_CMD="code" ; PKG_NAME="visual-studio-code-bin" ; DEB_RPM="code" ; FLATPAK_ID="com.visualstudio.code" ;;
        2) EDITOR_CMD="codium" ; PKG_NAME="vscodium-bin" ; DEB_RPM="codium" ; FLATPAK_ID="com.vscodium.codium" ;;
        3) EDITOR_CMD="cursor" ; PKG_NAME="cursor-bin" ; DEB_RPM="cursor" ; FLATPAK_ID="" ;;
        4) EDITOR_CMD="trae" ; PKG_NAME="trae-bin" ; DEB_RPM="trae" ; FLATPAK_ID="" ;;
        5) EDITOR_CMD="windsurf" ; PKG_NAME="windsurf-bin" ; DEB_RPM="windsurf" ; FLATPAK_ID="" ;;
        6) EDITOR_CMD="antigravity" ; PKG_NAME="google-antigravity-bin" ; DEB_RPM="antigravity" ; FLATPAK_ID="" ;;
        *) EDITOR_CMD="code" ; PKG_NAME="visual-studio-code-bin" ; DEB_RPM="code" ; FLATPAK_ID="com.visualstudio.code" ;;
    esac

    
    if command -v $EDITOR_CMD &> /dev/null; then
        echo -e "\033[1;32mFound $EDITOR_CMD installed via Package Manager! ✅\033[0m"
        FOUND=true
    elif command -v snap &> /dev/null && snap list 2>/dev/null | grep -q "^$EDITOR_CMD"; then
        echo -e "\033[1;32mFound $EDITOR_CMD installed via Snap! ✅\033[0m"
        EDITOR_CMD="snap run $EDITOR_CMD"
        FOUND=true
    elif [[ -n "$FLATPAK_ID" ]] && command -v flatpak &> /dev/null && flatpak list 2>/dev/null | grep -q "$FLATPAK_ID"; then
        echo -e "\033[1;32mFound $EDITOR_CMD installed via Flatpak! ✅\033[0m"
        EDITOR_CMD="flatpak run $FLATPAK_ID"
        FOUND=true
    fi
fi


if [ "$FOUND" = true ]; then
    set +e
    read -p "Do you want to install Assembly extensions for your editor? (y/n): " install_ext
    set -e
    if [[ "$install_ext" =~ ^[Yy]$ ]]; then
        echo "Installing extensions..."
        $EDITOR_CMD --install-extension 13xforever.language-x86-64-assembly --force
        $EDITOR_CMD --install-extension doinkythederp.nasm-language-support --force
        $EDITOR_CMD --install-extension usernamehw.errorlens --force
        echo -e "\033[1;32mExtensions setup complete! ✨\033[0m"
    fi
else
    echo -e "\033[1;31mThe selected editor is NOT found on your system.\033[0m"
    
    if [[ -z "$FLATPAK_ID" && "$editor_choice" -ne 1 && "$editor_choice" -ne 2 ]]; then
         echo -e "\033[1;33mNote: This editor is not available on Flathub, check AUR or official site.\033[0m"
    fi

    set +e
    read -p "Would you like me to suggest the installation command for $OS_ID? (y/n): " suggest_install
    set -e
    if [[ "$suggest_install" =~ ^[Yy]$ ]]; then
        case $OS_ID in
            arch|manjaro|endeavouros|cachyos) echo -e "Run: \033[1;33myay -S $PKG_NAME\033[0m" ;;
            debian|ubuntu|mint|zorin) echo -e "Run: \033[1;33m$SUDO_CMD apt install $DEB_RPM\033[0m (or download .deb/AppImage)" ;;
            *) echo "Please visit the official website to install the editor." ;;
        esac
    fi
fi

echo "------------------------------------------"
echo "Step 7: Setup asm-run command"
echo "------------------------------------------"

TARGET_PATH="/usr/bin/asm-run"

if [ -f "asm-run.sh" ]; then
    echo "Found local asm-run.sh. Copying to $TARGET_PATH..."
    $SUDO_CMD cp asm-run.sh "$TARGET_PATH"
else
    echo "Local asm-run.sh not found. Downloading from GitHub..."
    $SUDO_CMD curl -fsSL "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/asm-run.sh" -o "$TARGET_PATH"
fi

$SUDO_CMD chmod +x "$TARGET_PATH"

echo -e "\033[1;32mVerifying installed command content:\033[0m"
cat "$TARGET_PATH"


echo -e "\033[1;36mNow you can type the 'asm-run' command from the terminal even without a code editor, followed by the file name ending in .asm\033[0m"


echo "------------------------------------------"
echo -e "\033[1;35m🎉 ALL DONE! Your Ultimate Assembly Environment is 100% Ready! 🚀\033[0m"
echo "------------------------------------------"

echo "------------------------------------------"
echo -e "\033[1;35m i use archlinux BTW\033[0m"
echo "------------------------------------------"

echo "------------------------------------------"
echo -e "\033[1;35m فيه حمار قال اني مابفهمش لينكس عايز اقولك شوف ده يا حمار بشري\033[0m"
echo "------------------------------------------"

echo "------------------------------------------"
echo "Setup finished successfully!"
echo "------------------------------------------"