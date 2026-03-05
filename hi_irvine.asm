INCLUDE Irvine32.inc

.data
    msg BYTE "hi i use arch btw from win32 (Irvine Edition) from windows 10 pro vm", 0

.code
main PROC
    mov edx, OFFSET msg    ; نضع مسار النص في مسجل edx
    call WriteString       ; دالة جاهزة من مكتبة الدكتور للطباعة
    call Crlf              ; دالة جاهزة للنزول سطر جديد
    exit                   ; تعادل ExitProcess(0)
main ENDP
END main