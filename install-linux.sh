#!/bin/bash

set -e

C_SEP='\033[1;30m'
C_STEP='\033[1;34m'
C_TXT='\033[1;37m'
C_CMD='\033[0;36m'
C_SUC='\033[1;32m'
C_WRN='\033[1;33m'
C_ERR='\033[1;31m'
C_MAG='\033[1;35m'
C_RST='\033[0m'

trap 'echo -e "\n${C_ERR}Script interrupted! Cleaning up...${C_RST}"; rm -rf uasm_temp uasm_linux.zip irvine.zip irvine_temp.zip; exit 1' SIGINT

SUDO_CMD=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo &>/dev/null; then
    SUDO_CMD="sudo"
  else
    echo -e "${C_ERR}Error: You are not root and 'sudo' is not installed. Please run as root.${C_RST}"
    exit 1
  fi
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 0: Checking Internet Connectivity...${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

echo -en "${C_CMD}"
if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
  echo -en "${C_RST}"
  echo -e "${C_ERR}Error: No internet connection detected.${C_RST}"
  echo -e "${C_WRN}To ensure no errors occur because there is no internet currently, please run the script again when internet is available.${C_RST}"
  exit 1
fi
echo -en "${C_RST}"

echo -e "${C_TXT}Testing connection speed/stability...${C_RST}"
echo -en "${C_CMD}"
AVG_PING=$(ping -c 3 8.8.8.8 2>/dev/null | tail -1 | awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)
echo -en "${C_RST}"

if [[ "$AVG_PING" =~ ^[0-9]+$ ]] && [ "$AVG_PING" -gt 200 ]; then
  echo -e "${C_WRN}It seems the internet speed is slow (High Latency: ${AVG_PING}ms). Errors may occur during downloads.${C_RST}"

  set +e
  echo -en "${C_WRN}Do you want to continue? (y/n): ${C_RST}"
  read continue_script
  set -e

  if [[ ! "$continue_script" =~ ^[Yy]$ ]]; then
    echo -e "${C_CMD}No worries! Better luck next time. Catch you later when the connection is more stable! 🚀${C_RST}"
    exit 0
  else
    echo -e "${C_SUC}Alright, let's proceed with caution!${C_RST}"
  fi
else
  echo -e "${C_SUC}Internet connection looks good! ✅${C_RST}"
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 1: Detecting Linux Distribution & Checking Packages...${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
  OS_LIKE=$ID_LIKE
else
  OS_ID="unknown"
fi

check_packages_installed() {
  local missing=0

  local cmds=("nasm" "wine" "ghex" "unzip" "curl" "uasm")

  for cmd in "${cmds[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing=1
      break
    fi
  done

  if ! command -v x86_64-w64-mingw32-gcc &>/dev/null && ! command -v i686-w64-mingw32-gcc &>/dev/null; then
    missing=1
  fi

  if [ "$missing" -eq 0 ]; then
    echo -e "${C_SUC}All required packages are already installed! ✅ Skipping installation step.${C_RST}"
    return 1
  else
    echo -e "${C_WRN}Some required packages are missing.${C_RST}"
    while true; do
      set +e
      echo -en "${C_WRN}Do you want to install the missing packages? (y/n): ${C_RST}"
      read install_choice
      set -e

      case "$install_choice" in
      [Yy]*) return 0 ;;
      [Nn]*)
        echo -e "${C_WRN}Skipping installation as requested. (Warning: Some features might not work! ⚠️)${C_RST}"
        return 1
        ;;
      *) echo -e "${C_ERR}Invalid input. Please enter 'y' to install or 'n' to skip.${C_RST}" ;;
      esac
    done
  fi
}

install_uasm_manual() {
  if command -v uasm &>/dev/null; then
    echo -e "${C_TXT}uasm is already installed.${C_RST}"
  else
    echo -e "${C_TXT}Downloading and installing uasm binary for Linux...${C_RST}"
    echo -en "${C_CMD}"
    curl -fsSL "https://www.terraspace.co.uk/uasm257_linux64.zip" -o uasm_linux.zip
    echo -en "${C_RST}"

    echo -e "${C_TXT}Verifying uasm file integrity...${C_RST}"
    if command -v sha256sum &>/dev/null; then
      EXPECTED_UASM_HASH="d9fecb2226f66c7e48d81402fc13a67eda23507be9067a2983ee14ec7d68a94f"
      echo -en "${C_CMD}"
      ACTUAL_UASM_HASH=$(sha256sum uasm_linux.zip | awk '{print $1}')
      echo -en "${C_RST}"
      echo -e "${C_TXT}Expected: $EXPECTED_UASM_HASH${C_RST}"
      echo -e "${C_TXT}Actual:   $ACTUAL_UASM_HASH${C_RST}"

      if [ "$ACTUAL_UASM_HASH" != "$EXPECTED_UASM_HASH" ]; then
        echo -e "${C_ERR}Error: SHA256 mismatch for uasm! The file is corrupted or compromised.${C_RST}"
        rm -f uasm_linux.zip
        exit 1
      fi
      echo -e "${C_SUC}Integrity check passed! ✅${C_RST}"
    else
      echo -e "${C_WRN}Warning: 'sha256sum' command not found, skipping integrity check.${C_RST}"
    fi

    echo -e "${C_TXT}Extracting uasm...${C_RST}"
    echo -en "${C_CMD}"
    unzip -q uasm_linux.zip -d uasm_temp
    echo -e "Installing to /usr/local/bin..."
    $SUDO_CMD mv uasm_temp/uasm /usr/local/bin/
    $SUDO_CMD chmod +x /usr/local/bin/uasm
    rm -rf uasm_linux.zip uasm_temp
    echo -en "${C_RST}"
    echo -e "${C_SUC}uasm installed successfully!${C_RST}"
  fi
}

install_packages() {
  case $1 in
  arch)
    echo -e "${C_TXT}Installing for Arch-based system...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD pacman -S --needed --noconfirm nasm mingw-w64-gcc wine binutils ghex unzip curl
    echo -en "${C_RST}"

    echo -e "${C_TXT}Installing uasm via yay...${C_RST}"
    echo -en "${C_CMD}"
    if command -v yay &>/dev/null; then
      yay -S --needed --noconfirm uasm
      echo -en "${C_RST}"
    else
      echo -en "${C_RST}"
      echo -e "${C_WRN}Warning: 'yay' is not installed. Installing uasm manually...${C_RST}"
      install_uasm_manual
    fi
    ;;
  debian)
    echo -e "${C_TXT}Installing for Debian/Ubuntu-based system...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD apt update && $SUDO_CMD apt install -y nasm gcc-mingw-w64 wine binutils ghex unzip curl
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  fedora)
    echo -e "${C_TXT}Installing for Fedora-based system (Bazzit/Nobara)...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD dnf install -y nasm mingw64-gcc wine binutils ghex unzip curl
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  void)
    echo -e "${C_TXT}Installing for Void Linux...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD xbps-install -S nasm cross-x86_64-w64-mingw32-gcc wine binutils ghex unzip curl
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  gentoo)
    echo -e "${C_TXT}Installing for Gentoo...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD emerge --ask dev-lang/nasm dev-util/mingw64-toolchain app-emulation/wine-vanilla sys-devel/binutils dev-util/ghex app-arch/unzip net-misc/curl
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  solus)
    echo -e "${C_TXT}Installing for Solus...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD eopkg install nasm mingw-w64 wine binutils ghex unzip curl
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  suse)
    echo -e "${C_TXT}Installing for openSUSE...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD zypper install -y nasm mingw64-gcc wine binutils ghex unzip curl
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  alpine)
    echo -e "${C_TXT}Installing for Alpine Linux...${C_RST}"
    echo -en "${C_CMD}"
    $SUDO_CMD apk add --no-cache nasm mingw-w64-gcc wine binutils ghex unzip curl sed
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  puppy)
    echo -e "${C_TXT}Installing for Puppy Linux (using pkg)...${C_RST}"
    echo -en "${C_CMD}"
    pkg install nasm mingw-w64-gcc wine binutils ghex unzip curl
    echo -en "${C_RST}"
    install_uasm_manual
    ;;
  esac
}

if check_packages_installed; then
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
    echo -e "${C_WRN}Could not auto-detect distribution ($OS_ID).${C_RST}"
    echo -e "${C_TXT}1) Arch  2) Debian  3) Fedora  4) Void  5) Gentoo  6) Solus  7) openSUSE  8) Alpine${C_RST}"

    while true; do
      set +e
      echo -en "${C_WRN}Select your base (1-8): ${C_RST}"
      read choice
      set -e

      case $choice in
      1)
        install_packages arch
        break
        ;;
      2)
        install_packages debian
        break
        ;;
      3)
        install_packages fedora
        break
        ;;
      4)
        install_packages void
        break
        ;;
      5)
        install_packages gentoo
        break
        ;;
      6)
        install_packages solus
        break
        ;;
      7)
        install_packages suse
        break
        ;;
      8)
        install_packages alpine
        break
        ;;
      *)
        echo -e "${C_ERR}Error: '$choice' is invalid. This does not correspond to any supported distribution.${C_RST}"
        echo -e "${C_WRN}Please enter a valid number between 1 and 8.${C_RST}"
        ;;
      esac
    done
  fi
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 2: Downloading VS Code configs...${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

mkdir -p .vscode
files=("c_cpp_properties.json" "launch.json" "settings.json" "tasks.json")
LOCAL_DIR="install-linux"

if [ -d "$LOCAL_DIR" ]; then
  echo -e "${C_TXT}Found local directory: $LOCAL_DIR. Copying files...${C_RST}"
  echo -en "${C_CMD}"
  for file in "${files[@]}"; do
    if [ -f "$LOCAL_DIR/$file" ]; then
      cp "$LOCAL_DIR/$file" ".vscode/$file"
      echo -e "Copied $file from local storage."
    else
      echo -e "${C_WRN}Warning: $file not found in $LOCAL_DIR.${C_CMD}"
    fi
  done
  echo -en "${C_RST}"
else
  echo -e "${C_TXT}Local directory not found. Starting download from GitHub...${C_RST}"
  echo -en "${C_CMD}"
  for file in "${files[@]}"; do
    URL="https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux/$file"
    curl -fsSL "$URL" -o ".vscode/$file"
    echo -e "Downloaded $file"
  done
  echo -en "${C_RST}"
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 3: Downloading Irvine Library...${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

set +e
echo -en "${C_WRN}Do you want to download the Irvine Library? It is approximately 24 MB in size. (y/n): ${C_RST}"
read download_irvine
set -e

if [[ "$download_irvine" =~ ^[Yy]$ ]]; then
  echo -e "${C_TXT}Downloading Irvine.zip...${C_RST}"
  echo -en "${C_CMD}"
  curl -fsSL "http://www.asmirvine.com/gettingStartedVS2019/Irvine.zip" -o irvine.zip
  echo -en "${C_RST}"

  echo -e "${C_TXT}Verifying Irvine library integrity...${C_RST}"
  if command -v sha256sum &>/dev/null; then
    EXPECTED_IRVINE_HASH="3d084c092ddc775dd9969a9d5318f13fc7f74a806a4d710fc00f62df3b4c5a5e"
    echo -en "${C_CMD}"
    ACTUAL_IRVINE_HASH=$(sha256sum irvine.zip | awk '{print $1}')
    echo -en "${C_RST}"
    echo -e "${C_TXT}Expected: $EXPECTED_IRVINE_HASH${C_RST}"
    echo -e "${C_TXT}Actual:   $ACTUAL_IRVINE_HASH${C_RST}"

    if [ "$ACTUAL_IRVINE_HASH" != "$EXPECTED_IRVINE_HASH" ]; then
      echo -e "${C_ERR}Error: SHA256 mismatch for Irvine Library! The file is corrupted or compromised.${C_RST}"
      rm -f irvine.zip
      exit 1
    fi
    echo -e "${C_SUC}Integrity check passed! ✅${C_RST}"
  else
    echo -e "${C_WRN}Warning: 'sha256sum' command not found, skipping integrity check.${C_RST}"
  fi

echo -e "${C_TXT}Extracting Irvine library to /opt/irvine...${C_RST}"
  echo -en "${C_CMD}"
  $SUDO_CMD mkdir -p /opt/irvine
  $SUDO_CMD unzip -q -o irvine.zip -d /opt/irvine
  $SUDO_CMD chmod -R 755 /opt/irvine
  echo -e "Cleaning up..."
  rm irvine.zip
  echo -en "${C_RST}"
  echo -e "${C_SUC}Irvine library installed successfully in /opt/irvine!${C_RST}"
else
  echo -e "${C_TXT}Skipping Irvine library download.${C_RST}"
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 4: Updating launch.json paths...${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

CURRENT_DIR=$(pwd)
LAUNCH_FILE=".vscode/launch.json"

if [ -f "$LAUNCH_FILE" ]; then
  echo -en "${C_CMD}"
  sed -i "s|\"cwd\": \"/mnt/data/github_repos/asm\"|\"cwd\": \"$CURRENT_DIR\"|g" "$LAUNCH_FILE"
  sed -i "s|\"program\": \"/mnt/data/github_repos/asm/build/Debug/outDebug\"|\"program\": \"$CURRENT_DIR/build/Debug/outDebug\"|g" "$LAUNCH_FILE"
  echo -en "${C_RST}"
  echo -e "${C_SUC}Successfully updated paths in $LAUNCH_FILE to $CURRENT_DIR${C_RST}"
else
  echo -e "${C_WRN}Warning: $LAUNCH_FILE not found. Skipping path update.${C_RST}"
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 5: Downloading ASM Examples...${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

set +e
echo -en "${C_WRN}Do you want to download example Assembly files? (y/n): ${C_RST}"
read download_examples
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
    echo -e "${C_TXT} -> Fetching ${C_STEP}$file_name${C_TXT} via curl...${C_RST}"
    echo -en "${C_CMD}"
    curl -fsSL -o "$file_name" "$url"
    echo -en "${C_RST}"
  done
  echo -e "${C_SUC}Examples downloaded successfully!${C_RST}"
else
  echo -e "${C_TXT}Skipping example files download.${C_RST}"
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 6: Smart Editor Detection & Extension Setup${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

echo -e "${C_TXT}Scanning system for installed code editors...${C_RST}"

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
  IFS=':' read -r e_name e_cmd e_pkg e_deb e_flatpak <<<"$editor_data"

  if command -v "$e_cmd" &>/dev/null; then
    echo -e "${C_SUC}Auto-detected $e_name installed via Package Manager! ✅${C_RST}"
    EDITOR_CMD="$e_cmd"
    DETECTED_EDITOR="$e_name"
    FOUND=true
    break
  elif command -v snap &>/dev/null && snap list 2>/dev/null | grep -q "^$e_cmd"; then
    echo -e "${C_SUC}Auto-detected $e_name installed via Snap! ✅${C_RST}"
    EDITOR_CMD="snap run $e_cmd"
    DETECTED_EDITOR="$e_name"
    FOUND=true
    break
  elif [[ -n "$e_flatpak" ]] && command -v flatpak &>/dev/null && flatpak list 2>/dev/null | grep -q "$e_flatpak"; then
    echo -e "${C_SUC}Auto-detected $e_name installed via Flatpak! ✅${C_RST}"
    EDITOR_CMD="flatpak run $e_flatpak"
    DETECTED_EDITOR="$e_name"
    FOUND=true
    break
  fi
done

if [ "$FOUND" = false ]; then
  echo -e "${C_WRN}Could not automatically detect an installed editor.${C_RST}"
  echo -e "${C_TXT}Which editor are you using?${C_RST}"
  echo -e "${C_TXT}1) VS Code  2) VS Codium  3) Cursor  4) Trae  5) Windsurf  6) Google Antigravity${C_RST}"

  while true; do
    set +e
    echo -en "${C_WRN}Select your editor (1-6): ${C_RST}"
    read editor_choice
    set -e

    case $editor_choice in
    1)
      EDITOR_CMD="code"
      PKG_NAME="visual-studio-code-bin"
      DEB_RPM="code"
      FLATPAK_ID="com.visualstudio.code"
      break
      ;;
    2)
      EDITOR_CMD="codium"
      PKG_NAME="vscodium-bin"
      DEB_RPM="codium"
      FLATPAK_ID="com.vscodium.codium"
      break
      ;;
    3)
      EDITOR_CMD="cursor"
      PKG_NAME="cursor-bin"
      DEB_RPM="cursor"
      FLATPAK_ID=""
      break
      ;;
    4)
      EDITOR_CMD="trae"
      PKG_NAME="trae-bin"
      DEB_RPM="trae"
      FLATPAK_ID=""
      break
      ;;
    5)
      EDITOR_CMD="windsurf"
      PKG_NAME="windsurf-bin"
      DEB_RPM="windsurf"
      FLATPAK_ID=""
      break
      ;;
    6)
      EDITOR_CMD="antigravity"
      PKG_NAME="google-antigravity-bin"
      DEB_RPM="antigravity"
      FLATPAK_ID=""
      break
      ;;
    *) echo -e "${C_ERR}Error: Invalid choice. Please select a number between 1 and 6.${C_RST}" ;;
    esac
  done

  if command -v $EDITOR_CMD &>/dev/null; then
    echo -e "${C_SUC}Found $EDITOR_CMD installed via Package Manager! ✅${C_RST}"
    FOUND=true
  elif command -v snap &>/dev/null && snap list 2>/dev/null | grep -q "^$EDITOR_CMD"; then
    echo -e "${C_SUC}Found $EDITOR_CMD installed via Snap! ✅${C_RST}"
    EDITOR_CMD="snap run $EDITOR_CMD"
    FOUND=true
  elif [[ -n "$FLATPAK_ID" ]] && command -v flatpak &>/dev/null && flatpak list 2>/dev/null | grep -q "$FLATPAK_ID"; then
    echo -e "${C_SUC}Found $EDITOR_CMD installed via Flatpak! ✅${C_RST}"
    EDITOR_CMD="flatpak run $FLATPAK_ID"
    FOUND=true
  fi
fi

if [ "$FOUND" = true ]; then
  set +e
  echo -en "${C_WRN}Do you want to install Assembly extensions for your editor? (y/n): ${C_RST}"
  read install_ext
  set -e
  if [[ "$install_ext" =~ ^[Yy]$ ]]; then
    echo -e "${C_TXT}Installing extensions...${C_RST}"
    echo -en "${C_CMD}"
    $EDITOR_CMD --install-extension 13xforever.language-x86-64-assembly --force
    $EDITOR_CMD --install-extension doinkythederp.nasm-language-support --force
    $EDITOR_CMD --install-extension usernamehw.errorlens --force
    echo -en "${C_RST}"
    echo -e "${C_SUC}Extensions setup complete! ✨${C_RST}"
  fi
else
  echo -e "${C_ERR}The selected editor is NOT found on your system.${C_RST}"

  if [[ -z "$FLATPAK_ID" && "$editor_choice" -ne 1 && "$editor_choice" -ne 2 ]]; then
    echo -e "${C_WRN}Note: This editor is not available on Flathub, check AUR or official site.${C_RST}"
  fi

  set +e
  echo -en "${C_WRN}Would you like me to suggest the installation command for $OS_ID? (y/n): ${C_RST}"
  read suggest_install
  set -e
  if [[ "$suggest_install" =~ ^[Yy]$ ]]; then
    case $OS_ID in
    arch | manjaro | endeavouros | cachyos) echo -e "${C_TXT}Run: ${C_CMD}yay -S $PKG_NAME${C_RST}" ;;
    debian | ubuntu | mint | zorin) echo -e "${C_TXT}Run: ${C_CMD}$SUDO_CMD apt install $DEB_RPM${C_TXT} (or download .deb/AppImage)${C_RST}" ;;
    *) echo -e "${C_TXT}Please visit the official website to install the editor.${C_RST}" ;;
    esac
  fi
fi

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP}Step 7: Setup asm-run command${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

TARGET_PATH="/usr/bin/asm-run"

echo -en "${C_CMD}"
if [ -f "asm-run.sh" ]; then
  echo -e "Found local asm-run.sh. Copying to $TARGET_PATH..."
  $SUDO_CMD cp asm-run.sh "$TARGET_PATH"
else
  echo -e "Local asm-run.sh not found. Downloading from GitHub..."
  $SUDO_CMD curl -fsSL "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/asm-run.sh" -o "$TARGET_PATH"
fi

$SUDO_CMD chmod +x "$TARGET_PATH"
echo -en "${C_RST}"

echo -e "${C_SUC}Verifying installed command content:${C_RST}"
echo -en "${C_CMD}"
cat "$TARGET_PATH"
echo ""
echo -en "${C_RST}"

echo -e "${C_CMD}Now you can type the 'asm-run' command from the terminal even without a code editor, followed by the file name ending in .asm${C_RST}"

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_MAG}🎉 ALL DONE! Your Ultimate Assembly Environment is 100% Ready! 🚀${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_STEP} i use archlinux BTW${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

echo -e "${C_SEP}------------------------------------------${C_RST}"
echo -e "${C_SUC}Setup finished successfully!${C_RST}"
echo -e "${C_SEP}------------------------------------------${C_RST}"

