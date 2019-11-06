;
; similar to helloworld program but using puts() from the standard C library
;

global main
extern puts

section .data
msg: db "hello world using puts", 0xA, 0x0 ; puts adds a newline anyway but so what, I'm a rebel

section .text
main:
    mov rdi, msg    ; first integer or ptr arg is placed in rdi
    call puts       ; much easier than making sys_call

    ret ; instead of making exit syscall
