.data
    msg: .ascii "Hello from ARM32 Linux on Arch!\n"
    len = . - msg

.text
    .global _start

_start:
    mov r7, #4
    mov r0, #1
    ldr r1, =msg
    ldr r2, =len
    svc #0

    mov r7, #1
    mov r0, #0
    svc #0