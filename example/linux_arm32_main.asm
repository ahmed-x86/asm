.data
    msg: .ascii "Hello from ARM32 (main) on Arch Linux!\n"
    len = . - msg

.text
    .global main

main:
    mov r7, #4
    mov r0, #1
    ldr r1, =msg
    ldr r2, =len
    svc #0

    mov r7, #1
    mov r0, #0
    svc #0