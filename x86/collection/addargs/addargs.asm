;
;   program adds first (starting from the right in C) 
;   N arguments and returns the sum
;

section .data
    addargerr: db "sumargvec: malformed argument", 0x00
section .bss
section .text

; tell assembler this function is located elsewhere
; gcc will find puts in glibc during the link process
extern puts

; behold the power of variadic functions!!
global sumargvec
sumargvec:

    mov ecx, DWORD [esp+4]

    ; return if there arent anymore arguments. if we can rely on 
    ; programmers to not abuse this... haha jk
    cmp ecx, 0    ; prep for jump
    jg sumargbegin      ; dont continue if there are zero or less arguments

    ; give error message before returning
    push DWORD addargerr    ; prep the error message
    call puts   ; print the error
    add esp, 4  ; caller cleans up

    ; return if improperly formed argument list
    mov eax, DWORD [esp+4]  ; return requested number of parameters to caller
    ret ; exit subroutine early

  sumargbegin:
    ; prep ecx (used to index esp to grab rest of arguments)
    add ecx, 1  ; need to go one extra index (arg list: N, N args)
    shl ecx, 2  ; multiply by 4 (4 bytes per integer to add)

    ;
    ; a word on multiplies
    ;
    ; the reason i dont use a mul instruction here is that (i)mul instructions 
    ; take more than one register to perform whereas shifts and adds can be 
    ; done in-place with a single register. x86-32 famously has a ridiculously 
    ; small number of general purpose registers
    ;

    ; meat of sumargvec
    mov eax, DWORD 0    ; prep eax for addition

  sumargvloop:
    add eax, [esp+ecx]  ; add a stack item to running total
    add ecx, -4         ; prep next index
    cmp ecx, DWORD 4    ; we need to stop at 4
    jg sumargvloop     ; loop until finished

    ret

