.data
    msg: .ascii "Hello from RISC-V 32-bit (RV32E) using main on Linux!\n"
    len = . - msg

.text
    .global main

main:
    li t0, 64
    li a0, 1
    la a1, msg
    li a2, len
    ecall

    li t0, 93
    li a0, 0
    ecall