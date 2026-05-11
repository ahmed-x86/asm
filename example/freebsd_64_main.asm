section .data
    msg db "Hello from FreeBSD 64-bit on Arch Linux!", 10
    len equ $ - msg

section .text
    global main

main:
    mov rax, 4
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 1
    xor rdi, rdi
    syscall