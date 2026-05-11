section .data
    msg db "Hello from Arch Linux (64-bit Native) using main!", 10
    len equ $ - msg

section .text
    global main

main:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall