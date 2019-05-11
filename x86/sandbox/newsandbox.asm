section .data
    digit_lut: db "0123456789"
    digit_lut_len: equ $ - digit_lut ; let assembler figure out the length of the string (10 bytes obviously)
    newline_char: db 0x0A

section .bss
section .text

global _start

_start:
    nop ; start NOP

    mov eax, 4000 ; currently should print backwards
    call print_unsigned_int
    call print_newline

    nop ; end NOP

    ; standard way to exit programs in Linux
    mov eax, 1 ; sys_exit
    mov ebx, 0 ; return value of 0
    int 80H    ; software interrupt

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
    mov eax, 1 ; syscall 1
    mov ebx, 0 ; return value of 0
    int 80H    ; software interrupt

; assumes that required number is already in register EAX
print_unsigned_int:
    push edx   ; will need this for division operations
    mov edx, 0 ; load zero for first comparison
    
    cmp eax, edx ; prep branch
    jne print_unsigned_start ; branch if we actually have work to do
    
    pop edx ; put back where we got it from
    ret     ; return to caller

    ; for now, we will only print the lowest decimal character in the number
  print_unsigned_start:
    mov edx, 0      ; edx:eax / <divisor>
    mov ecx, 10
    div ecx         ; remainder is in edx (as per the instruction documentation)
    push eax        ; will get overwritten by syscall later

    ; sys_write
    ;       ecx : address of char(s) to write
    ;       ebx : file descriptor to write to
    ;       eax : 4 (sys_write syscall)
    ;       edx : number of chars to write
    mov eax, 4  ; sys_write
    mov ecx, digit_lut ; prep the address for sys_write
    add ecx, edx       ; calculate proper offset of actual character to write
    mov ebx, 1  ; STDOUT
    mov edx, 1  ; write 1 character
    int 80H     ; generate interrupt

    pop eax         ; saved from before interrupt
    mov edx, 0      ;
    cmp eax, edx    ; prep branch again
  jne print_unsigned_start

    ; the routine is over now
    pop edx ; saved at the veeery start of the subroutine
    ret     ; return to caller
