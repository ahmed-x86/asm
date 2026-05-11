section .data
    msg db "Hello from FreeBSD 32-bit on Arch Linux!", 10
    len equ $ - msg

section .text
    global _start

_start:
    push dword len
    push dword msg
    push dword 1
    push dword 0
    mov eax, 4
    int 0x80
    add esp, 16

    push dword 0
    push dword 0
    mov eax, 1
    int 0x80