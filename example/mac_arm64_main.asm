.data
    msg: .ascii "hi i use arch btw by mac-arm64\n"
    len = . - msg

.text
    .global _main
    .align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x0, #1
    adrp x1, msg@PAGE
    add x1, x1, msg@PAGEOFF
    mov x2, len
    bl _write

    mov x0, #0
    ldp x29, x30, [sp], #16
    ret