section .data
    int_string: db 0x25, "d", 0x0a, 0x00
    ;               %     d    \n    \0
section .bss
section .text

extern printf

;
;   this function demonstrates iterating over a 
;   linked list. it follows the given pointer 
;   until it encounters NULL
;
;   refer to main.c to see the structure of the 
;   node used in the list
;
; not bragging or anything, but... I use 13 instructions.
; with current compiler settings, gcc produces 19 instructions.
; with size optimization, gcc produces 17 instructions
;

global listiter
listiter:

    mov eax, DWORD [esp+4] ; load the first pointer. we will follow this to the end

  loop_start:
    push eax ; save before calling printf
    
    push DWORD [eax+4]      ; pass the integer
    push DWORD int_string   ; config string
    call printf ; call that sweet printf function
    add esp, 8  ; clean the stack

    pop eax ; saved this before the printf call

    ; follow the yellow brick road...
    mov ecx, [eax]  ; load the 'next' pointer
    cmp ecx, 0      ; test for NULL pointer
    je subr_end

    ; we have at least one node left
    mov eax, ecx    ; move the pointer for next iteration
    jmp loop_start  ; back to the beginning

  subr_end:
    ret

;
; testing more pointer stuff while interfacing with C
; tried to optimize this even more. this function follows 
; a linked list and calls a callback with each data item in the list
;
; this function does MORE than the above function with 
; fewer instructions, but it probably doesnt run as quickly
; 10 instructions (less than 13!!) but more stack accesses
;

global listitercall
listitercall:

    mov eax, DWORD [esp+4]  ; grab the node pointer

    ; dont need this anymore because we grab the callback 
    ; address directly from the stack when we need it
    ;mov ebx, DWORD [esp+8]  ; grab the callback address

  listitercall_loop:

    push eax    ; save the value of eax

    push DWORD [eax+4]  ; push the argument onto the stack
    call DWORD [esp+16] ; callback time ( ind(16) because we just pushed more things onto the stack )
    add esp, 4  ; clean up the stack

    pop eax     ; restore the value of eax

    mov eax, DWORD [eax]  ; advance the pointer to the next node
    cmp eax, 0
    jne listitercall_loop

    ; end of the road
    ret

;
; function to count how many elements are in a linked list.
; iterates through the list incrementing a counter each time
;

global listsize
listsize:
    mov ebx, DWORD [esp+4]  ; grab list pointer
    xor eax, eax    ; starting size of zero

    ; some error checking
    cmp ebx, 0          ; test if we were passed a NULL ptr
    jne listsize_loop
    ret                 ; dont continue. list size is zero

  listsize_loop:
    
    mov ebx, DWORD [ebx]    ; move through the list by one node
    inc eax
    cmp ebx, 0
    jne listsize_loop

    ret
