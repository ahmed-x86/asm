.data
    msg: .ascii "Hello from RISC-V 128-bit Linux on Arch!\n"
    len = . - msg

.text
    .global _start

_start:
    li a7, 64
    li a0, 1
    la a1, msg
    li a2, len
    ecall

    li a7, 93
    li a0, 0
    ecall