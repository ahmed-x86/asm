.data
    msg: .ascii "Hello from ARM64 Linux on Arch!\n"
    len = . - msg

.text
    .global _start

_start:
    mov x8, #64
    mov x0, #1
    ldr x1, =msg
    ldr x2, =len
    svc #0

    mov x8, #93
    mov x0, #0
    svc #0