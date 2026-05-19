section .data
    msg1 db "hi i use arch btw by freebsd32 (main)", 10
    len equ $ - msg1

section .text
    global main

main:
    push dword len
    push dword msg1
    push dword 1
    push dword 0
    mov eax, 4
    int 0x80
    add esp, 16

    push dword 0
    push dword 0
    mov eax, 1
    int 0x80