.data
    msg: .ascii "Hello from RISC-V 64-bit (main)Linux on Arch!\n"
    len = . - msg

.text
    .global main

main:
    li a7, 64
    li a0, 1
    la a1, msg
    li a2, len
    ecall

    li a0, 0
    ret