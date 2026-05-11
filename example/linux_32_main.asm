section .data
    msg db "Success: Linux 32-bit (x86) is running perfectly on Arch!", 10
    len equ $ - msg

section .text
    global main

main:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, len
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80