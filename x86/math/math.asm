; this program was written only to test the 
; DIV instruction. a previous asm program kept 
; causing a Floating point exception

section .data
section .bss
section .text

global _start

_start:
    nop ; start NOP

    ; DIV: edx:eax / <divisor>
    mov edx, 0
    mov eax, 16

    ; this method works pretty well as DIV doesnt let you divide by a 32-bit immediate
    mov ecx, 4
    div ecx

    ; quotient is now in eax
    ; remainder (modulus) is in edx

    nop ; end NOP

    ; standard way to exit programs in Linux
    mov eax, 1 ; sys_exit
    mov ebx, 0 ; return value of 0
    int 80H    ; software interrupt
