format ELF64 executable

segment readable executable

entry start

start:
    ; Your code here
    
    ; Exit program
    mov rax,60		; sys_exit
    xor rdi,rdi		; exit code 0
    syscall
