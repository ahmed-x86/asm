.data
    msg: .ascii "Success: RISC-V 32-bit (RV32I) using main works!\n"
    len = . - msg

.text
    .global main

main:
    li a7, 64
    li a0, 1
    la a1, msg
    li a2, len
    ecall

    li a7, 93
    li a0, 0
    ecall