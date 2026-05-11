format ELF executable 3

segment readable executable

entry start

start:
    ; Your code here
    
    ; Exit program
    mov eax,1		; sys_exit
    xor ebx,ebx		; exit code 0
    int 0x80

segment readable writeable

    ; Data here
