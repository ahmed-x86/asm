.data
    msg: .ascii "Hello from ARM64 (main) on Arch Linux!\n"
    len = . - msg

.text
    .global main

main:
    mov x8, #64
    mov x0, #1
    adrp x1, msg
    add x1, x1, :lo12:msg
    mov x2, len
    svc #0

    mov x8, #93
    mov x0, #0
    svc #0