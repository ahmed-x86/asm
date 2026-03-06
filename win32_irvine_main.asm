INCLUDE Irvine32.inc

.data
    msg BYTE "1. Task 6 Success: Win32 Irvine with main is working perfectly!", 0

.code
main PROC
    mov edx, OFFSET msg
    call WriteString
    call Crlf
    exit
main ENDP
END main