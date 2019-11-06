;
; Program: exit syscall
;
; executes the exit system call
;
; no input
;
; outputs the exit status
;

segment .text
global _start

_start:
    mov eax, 1  ; sysexit
    mov ebx, 5  ; status value to return
    int 0x80    ; software interrupt

