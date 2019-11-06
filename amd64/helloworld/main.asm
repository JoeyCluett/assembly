;
; write 'hello world' to stdout
; uses syswrite call
;

global _start

section .data
    message: db "hello world", 0xA ; hello world followed by newline
    message_length: equ $ - message

section .text
_start:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout file descriptor
    mov rsi, message    ; address of string
    mov rdx, message_length ; number of bytes to write
    syscall             ; software interrupt

    ; now time to exit cleanly
    mov rax, 60   ; sys_exit
    xor rdi, rdi    ; return value 0
    ;mov rdi, 0     ; could also use this to zero rdi
    syscall         ; software interrupt
