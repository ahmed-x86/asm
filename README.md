# Assembly Development Environment 🚀

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

An all-in-one repository designed to kickstart your Assembly (ASM) development on Linux. This environment provides out-of-the-box support for Linux x64 and Windows (32/64-bit) targets, featuring pre-configured VS Code settings for a seamless workflow.
🛠️ Installation

You can set up your environment using one of the two following methods:
## 1. One-Line Installer (Online)

Use this command to configure your current directory immediately without cloning the entire repo:

```
bash <(curl -sSL https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux.sh)
```
## 2. Local Setup (Manual)

If you have already cloned the repository or prefer a manual installation:
Bash
```
git clone https://github.com/ahmed-x86/asm.git
cp -r asm/. .
chmod +x install-linux.sh
./install-linux.sh
```
## ✨ Key Features

Smart Distro Detection: Automatically detects and installs dependencies for Arch Linux, Debian/Ubuntu, and Fedora.

VS Code Integration: Pre-configured tasks.json and launch.json allow you to build and run your code with a single shortcut (Ctrl+Shift+B).

Cross-Platform Support: Ready-to-use toolchains (NASM, MinGW-w64, Wine) to compile and test Windows binaries directly from your Linux terminal.

Optimized for Arch: Because "I use Arch btw" shouldn't mean spending three hours on config. 😎

## 💡 Improvements Made:

Terminology: Changed "Direct Installation" to "One-Line Installer," which is more common in DevOps circles.

Clarity: Specified that the VS Code integration handles both building and debugging.

Tone: Kept the "Arch Linux" humor but refined the technical descriptions to sound more authoritative.

---