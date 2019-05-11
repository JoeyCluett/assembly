;
;   x86 asm program to print an integer (refer to line 32)
;   
;   previous program printed integers backwards and 
;   always saw int as positive. this one accepts positive 
;   and negative integers and prints the negative symbol 
;   when required
;
;   This program uses x86 (32-bit) assembly. It SHOULDN'T
;   require many changes to successfully port to AMD64 assembly
;

section .data
    digit_lut: db "0123456789" ; look up table for binary->decimal digit conversion
    digit_lut_len: equ $ - digit_lut ; let assembler figure out the length of the string. this is NOT a new data item
    newline_char: db 0x0A   ; \n
    neg_sym: db 0x2D        ; '-'

section .bss
    ; no uninitialized data

section .text

;global _start
;_start:
;global main ; without _start gcc creates one for us and calls main from it
;main:       ; main label

    ; nop ; start NOP for debugging

    ; push eax    ; really dont need to save this but we will anyway
    ; mov eax, -1000000000    ; number to print
    ; call print_int          ; expects argument in eax
    ; call print_newline      ; doesnt accept arguments
    ; pop eax

    ; nop ; end NOP for debugging

    ; ; standard way to exit programs in Linux
    ; mov eax, 1 ; sys_exit
    ; mov ebx, 0 ; return value of 0
    ; int 80H    ; software interrupt

; this integer printing function stores all of the digits on the 
; stack before iterating through in reverse. assumes integer 
; is passed in eax. also supports negative numbers
global print_int
print_int:

    ; for use with C (32-bit Linux ABI)
    ;mov eax, [ebp + 8]
    ;mov eax, [ebp - 4] ; trying to find my argument
    ;mov eax, ebx
    ;mov eax, [ebp - 8]
    ;mov eax, [esp-4]

    mov eax, [ebp-12] ; FOUND IT!!
    ; argument explanation:
    ; ebp-0     previous stack frame ptr value
    ; ebp-4     padding (not cleared, could be anything here)
    ; ebp-8     padding (not cleared)
    ; ebp-12    right-most argument passed
    ;

    push ebx    ; callee saved register
    push eax    ; this is pushed last because we may need it in a bit and 
                ; the top of the stack is the most convenient location for it

    ; main digit loop assumes eax is positive
    cmp eax, 0
    jge sentinal_prep ; skip next part if eax is already positive
    
    ; negate eax and print negative sign
    mov eax, 4  ; sys_write (notice that this overwrites eax, which we need)
    mov ebx, 1  ; stdout
    mov ecx, neg_sym
    mov edx, 1  ; 1 char
    int 80H     ; call kernel interrupt

    mov eax, DWORD [esp] ; grab the value currently on top of the stack. it is the copy of eax we saved earlier
    neg eax ; change the sign <- IMPORTANT: wont print correctly if this doesnt happen

  sentinal_prep:
    ; push known sentinal value on the stack
    push DWORD -1 ; DWORD: 32-bit value, coerced if necessary

  get_one_digit:
    mov edx, 0  ; needs to be zero or result wont make sense
    mov ecx, 10 ; prep divisor
    div ecx     ; remainder: edx, quotient: eax

    push edx   ; modulus of last operation
    cmp eax, 0 ; repeat while not 0
    jne get_one_digit

  print_digits:
    pop ecx     ; retrieve the next value from the stack
    cmp ecx, -1 ; is this the sentinal?
    je clean_up_print_int

    ; this is where we pop the digits off of the stack 
    ; and print them in the proper order
    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    add ecx, digit_lut ; find correct character
    mov edx, 1 ; 1 character
    int 80h

    jmp print_digits ; x86 goto (cant get around it in assembly)

  clean_up_print_int:

    ; return the registers back to their proper locations
    pop eax ; this is just to clean the stack
    pop ebx ; this register is callee saved

    ret ; go back to caller

print_newline:
    push eax
    push ebx
    push ecx
    push edx

    mov eax, 4  ; sys_write
    mov ebx, 1  ; STDOUT
    mov ecx, newline_char ; address of starting char
    mov edx, 1  ; 1 character
    int 80h

    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

; let kernel clean up after us here, dont do for regular stuff!!
exit_early:
    nop
    mov eax, 1 ; sys_exit
    mov ebx, 1 ; return value of 1 (improper exit)
    int 0x80    ; software interrupt

; ...not bad
