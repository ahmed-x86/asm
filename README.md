

# Assembly Development Environment 🚀

![Windows 10](https://img.shields.io/badge/Windows_10-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows_11-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Windows 7](https://img.shields.io/badge/Windows_7-0078D6?style=for-the-badge&logo=windows&logoColor=white)

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Manjaro](https://img.shields.io/badge/Manjaro-35BF5C?style=for-the-badge&logo=manjaro&logoColor=white)
![CachyOS](https://img.shields.io/badge/CachyOS-0080FF?style=for-the-badge&logo=arch-linux&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E9433F?style=for-the-badge&logo=ubuntu&logoColor=white)
![Linux Mint](https://img.shields.io/badge/Linux_Mint-87CF3E?style=for-the-badge&logo=linux-mint&logoColor=white)
![ZorinOS](https://img.shields.io/badge/Zorin_OS-0CC0DF?style=for-the-badge&logo=zorin-os&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)
![Nobara](https://img.shields.io/badge/Nobara-750000?style=for-the-badge&logo=fedora&logoColor=white)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-557CF2?style=for-the-badge&logo=kali-linux&logoColor=white)
![Parrot OS](https://img.shields.io/badge/Parrot_OS-36C5CC?style=for-the-badge&logo=parrot-security&logoColor=white)
![Gentoo](https://img.shields.io/badge/Gentoo-54487A?style=for-the-badge&logo=gentoo&logoColor=white)
![Void Linux](https://img.shields.io/badge/Void_Linux-47841F?style=for-the-badge&logo=void-linux&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![Bazzit](https://img.shields.io/badge/Bazzit-525865?style=for-the-badge&logo=fedora&logoColor=white)
![Peppermint](https://img.shields.io/badge/Peppermint_OS-E11221?style=for-the-badge&logo=peppermint&logoColor=white)
![Puppy Linux](https://img.shields.io/badge/Puppy_Linux-B22222?style=for-the-badge&logo=linux&logoColor=white)
![openSUSE](https://img.shields.io/badge/openSUSE-73BA48?style=for-the-badge&logo=opensuse&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-0D597F?style=for-the-badge&logo=alpine-linux&logoColor=white)


### An all-in-one repository designed to kickstart your Assembly (ASM) development. This environment provides out-of-the-box support for Linux x64 and Windows (x86/x64), featuring pre-configured VS Code settings for a seamless workflow.

-----

## 🛠️ Quick Installation

Choose your weapon (Operating System) and run the corresponding command to configure your environment immediately:

## 🐧 Linux (One-Line Installer)

Supports Arch, Debian/Ubuntu, Fedora, Alpine, openSUSE, Solus, Gentoo, Puppy Linux, and Void.

```bash
bash <(curl -sSL https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux.sh)
```

### 🪟 Windows 10 / 11 (PowerShell Installer)

Optimized for modern Windows environments.

```powershell
irm https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows.ps1 | iex
```

### 🏛️ Windows 7 (Legacy Support)

Dedicated script for Windows 7 compatibility.

```powershell
irm https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows7.ps1 | iex
```

-----

## 🏗️ Manual Setup (Local)

If you prefer to clone the repository and run the scripts locally:

**For Linux:**

```bash
git clone https://github.com/ahmed-x86/asm.git
cd asm
chmod +x install-linux.sh
./install-linux.sh

```

**For Windows (All Versions):**

```powershell
git clone https://github.com/ahmed-x86/asm.git
cd asm
# For Win 10/11:
.\install-windows.ps1
# For Win 7:
.\install-windows7.ps1
```

-----

## ✨ Key Features

  * **Dual-Platform Support:** Native installers for both Windows and Linux, ensuring your dev environment is consistent everywhere.
  * **VS Code Integration:** Pre-configured `tasks.json` and `launch.json` allow you to build and debug your code with a single shortcut (`Ctrl+Shift+B`).
  * **Global CLI Tool:** Installs the custom `asm-run` command globally, allowing you to compile and test `.asm` files directly from any terminal without opening an editor.
  * **Smart Dependency Management:**
      * **On Linux:** Automatically detects your package manager (`pacman`, `apt`, `dnf`, `xbps`, `emerge`, `zypper`, `apk`, `pkg`), checks for existing packages to skip unnecessary downloads, and installs required tools (`NASM`, `GCC`, `Wine`, `UASM`).
      * **On Windows:** Sets up NASM and required build tools automatically.
  * **Legacy Support:** Special installer for **Windows 7** to ensure assembly development isn't limited by OS version.
  * **Cross-Compilation:** Ready-to-use toolchains to compile and test Windows binaries directly from Linux using Wine and MinGW.

## 🧠 Smart Engine Features

  * **Bulletproof Execution:** Features built-in network stability checks, strict input validation loops (idiot-proof inputs), and a `Ctrl+C` trap that automatically cleans up partial downloads if interrupted.
  * **Security First:** Implements rigorous **SHA256 Integrity Checks** for external binaries (uasm, Irvine library) to guarantee file authenticity and prevent corrupted extractions.
  * **Editor Agnostic:** Automatically scans and detects your installed IDE (**VS Code, VSCodium, Cursor, Trae, Windsurf, or Google Antigravity**) and sets up Assembly extensions (Syntax Highlighting & Error Lens).
  * **Universal Package Tracking:** Detects if your editor is installed via **Native Package Manager, Snap, or Flatpak** and configures extensions using the correct isolated commands.
  * **Auto-Path Patching:** Dynamically updates `launch.json` and `tasks.json` based on your current OS username and directory path. No manual editing required\!
  * **Alpine Compatibility:** Includes a dedicated pre-step to fix `sed` compatibility on Alpine Linux.

-----

## 🎭 Final Note

> [\!IMPORTANT]
> This project was built to prove that "Understanding Linux" isn't about talking, it's about building solutions that work on **9+ distributions** with a single click.

  - `echo -e "\033[1;35m فيه حمار قال اني مابفهمش لينكس.. عايز اقولك شوف السكربت ده يا حمار بشري\033[0m"`

**Stay Hard, Keep Coding. 🚀**

> **Note for Arch Users:** Because "I use Arch btw" shouldn't mean spending three hours on config. We've got you covered. 😎

-----

# i use arch btw

-----