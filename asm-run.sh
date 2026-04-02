#!/bin/bash

if [ -z "$1" ]; then
    echo "Oops, looks like you forgot the filename! 😅"
    echo "Try running it like this: $0 <filename.asm>"
    exit 1
fi

file="$1"

if [ ! -f "$file" ]; then
    echo "Hmm... I can't seem to find '$file'. Are you sure it's in this folder? 🤔"
    exit 1
fi

base="${file%.asm}"

echo "Choose build mode:"
echo "1) Linux64 Native (_start)"
echo "2) Linux64 Native (main)"
echo "3) Linux32 Native (_start)"
echo "4) Linux32 Native (main)"
echo "5) Win32 Irvine"
echo "6) Win32 Standalone"
echo "7) Win64 Standalone"
echo "8) Win32 Irvine (main)"
echo "9) Win32 Standalone (main)"
echo "10) Win64 Standalone (main)"

read -p "Option: " opt

case $opt in
    1)
        nasm -f elf64 "$file" -o "$base.o" && ld "$base.o" -o "$base" && ./"$base"
        ;;
    2)
        nasm -f elf64 "$file" -o "$base.o" && ld -e main "$base.o" -o "$base" && ./"$base"
        ;;
    3)
        nasm -f elf32 "$file" -o "$base.o" && ld -m elf_i386 "$base.o" -o "$base" && ./"$base"
        ;;
    4)
        nasm -f elf32 "$file" -o "$base.o" && ld -m elf_i386 -e main "$base.o" -o "$base" && ./"$base"
        ;;
    5)
        uasm -q -coff -I/opt/irvine "$file" -Fo"$base.o" && \
        i686-w64-mingw32-gcc "$base.o" /opt/irvine/Irvine32.lib -o "$base.exe" -nostdlib -lkernel32 -luser32 && \
        WINEDEBUG=-all wine "$base.exe"
        ;;
    6)
        nasm -f win32 "$file" -o "$base.obj" && \
        i686-w64-mingw32-gcc "$base.obj" -o "$base.exe" -nostartfiles -lkernel32 -luser32 && \
        WINEDEBUG=-all wine "$base.exe"
        ;;
    7)
        nasm -f win64 "$file" -o "$base.obj" && \
        x86_64-w64-mingw32-gcc "$base.obj" -o "$base.exe" -nostartfiles -lkernel32 -luser32 && \
        WINEDEBUG=-all wine "$base.exe"
        ;;
    8)
        uasm -q -coff -I/opt/irvine "$file" -Fo"$base.o" && \
        i686-w64-mingw32-gcc "$base.o" /opt/irvine/Irvine32.lib -o "$base.exe" -nostdlib -lkernel32 -luser32 -Wl,-e_main && \
        WINEDEBUG=-all wine "$base.exe"
        ;;
    9)
        nasm -f win32 "$file" -o "$base.obj" && \
        i686-w64-mingw32-gcc "$base.obj" -o "$base.exe" -nostartfiles -lkernel32 -luser32 -Wl,-e_main && \
        WINEDEBUG=-all wine "$base.exe"
        ;;
    10)
        nasm -f win64 "$file" -o "$base.obj" && \
        x86_64-w64-mingw32-gcc "$base.obj" -o "$base.exe" -nostartfiles -lkernel32 -luser32 -Wl,-emain && \
        WINEDEBUG=-all wine "$base.exe"
        ;;
    *)
        echo "Whoops, that's not on the menu! Try picking a number from 1 to 10 next time. 😉"
        exit 1
        ;;
esac