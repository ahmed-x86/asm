default rel

global _main
extern _write

section .data
    msg db "Hello macOS 64-bit from Arch Linux! (The Apple Way)", 10
    len equ $ - msg

section .text
_main:
    sub rsp, 8

    mov rdi, 1
    lea rsi, [msg]
    mov rdx, len
    call _write

    add rsp, 8
    xor rax, rax
    ret