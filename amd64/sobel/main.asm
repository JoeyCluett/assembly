;
; an assembly program that applies the Sobel operator to an
; image array that is already in memory. it needs to know
; the height and width of the image and needs a src array
; to read from and a dest array to write results to
;
; the sobel operator is a 3x3 image kernel:
;
;  -1  -2  -1
;   0   0   0
;   1   2   1
;
; this program does not pad anything. it simply ignores the
; outermost rows and columns of the input image
;

extern printf

global apply_sobel

; .data section stores the data for the Sobel operator. this can be changed
section .data
    sobel:      dq -1.0e1, -2.0e1, -1.0e1
    sobelr1:    dq  0.0e1,  0.0e1,  0.0e1
    sobelr2:    dq  1.0e1,  2.0e1,  1.0e1

    print_ptr_format:   db "%p", 0xA, "%p", 0xA, "%p", 0xA, 0x0
    print_int:          db "Y = %d, X = %d", 0xA, 0x0
    image_size_fmt:     db "H = %d, W = %d", 0xA, 0x0
    print_pointer:      db "Ptr: %p", 0xA, 0x0

section .text
apply_sobel:
    ; create stack frame
    push rbp        ; save the previous value of rbp
    mov rbp, rsp    ; rbp now points at its own previous value this creates a 'stack trace'
    sub rsp, 72     ; allocate 80 bytes for local storage

    ;
    ; arguments:
    ; rdi : src image
    ; rsi : dest image
    ; rdx : image height
    ; rcx : image width
    ;

    ; print the address of the src image
    push rdi
    ;mov rdi, rdi
    call print_pointer_subroutine
    pop rdi

    ; print the address of the dest image
    push rsi
    mov rdi, rsi
    call print_pointer_subroutine
    pop rsi

    ; do nothing if either of the sizes is less than 3
    cmp rdx, 3
    jl clean_and_return
    cmp rcx, 3
    jl clean_and_return

    ; now the actual calculation can begin
    ; first subtract 2 from each dimension
    sub rdx, 2 ; img h
    sub rcx, 2 ; img w
    shl rcx, 3 ; rcx is now the width of each row in bytes

    ;jmp clean_and_return

    xor r8, r8 ; height track
    ;xor r9, r9 ; width track

    ; TODO : place the sobel operator coefficients in registers where possible

  outer_loop:

    xor r9, r9  ; zero out every width iteration

  inner_loop:

    ; ========================================
    ; HERE BE DRAGONS
    ; ========================================

    subsd xmm0, xmm0    ; need a zero to start adding to

    mov  r10, r8   ; r8 is the current vertical index
    imul r10, rcx  ; generate the byte offset for this row
    add  r10, r9   ; r9 is the byte offset of the current element
    add  r10, rdi  ; add the base pointer before fetching

    movsd xmm1, QWORD [sobel] ; fetch upper left sobel coeffient
    mulsd xmm1, QWORD [r10]   ; fetch the current element
    addsd xmm0, xmm1    ; add to the cumulative sum for this window

    ; look at this awesome clusterf*ck of RAW and WAW hazards!!

    movsd xmm1, QWORD [sobel + 0]
    mulsd xmm1, QWORD [r10 + 0]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 8]
    mulsd xmm1, QWORD [r10 + 8]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 16]
    mulsd xmm1, QWORD [r10 + 16]
    addsd xmm0, xmm1

    add r10, rcx  ; jump to the next row in the src array

    movsd xmm1, QWORD [sobel + 24]
    mulsd xmm1, QWORD [r10 + 0]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 32]
    mulsd xmm1, QWORD [r10 + 8]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 40]
    mulsd xmm1, QWORD [r10 + 16]
    addsd xmm0, xmm1

    add r10, rcx   ; jump to the next row in the src array

    movsd xmm1, QWORD [sobel + 48]
    mulsd xmm1, QWORD [r10 + 0]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 56]
    mulsd xmm1, QWORD [r10 + 8]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 64]
    mulsd xmm1, QWORD [r10 + 16]
    addsd xmm0, xmm1

    ; we can calculate the destination address using r10 as its no longer needed at this point
    ;mov r10, ...
    ;mov r11, ...

    ; condition for next x
    ;inc r9
    add r9, 8
    cmp r9, rcx
    jl inner_loop

    ; condition for next y
    inc r8
    cmp rdx, r8
    jne outer_loop

  clean_and_return:
    ; destroy stack frame
    add rsp, 72 ; deallocate the stack space we requested
    pop rbp     ; remove this part of the stack trace
    ret         ; jump back to caller

    ; exceptional condition: invalid image size
  invalid_image_size:
    jmp clean_and_return ; jump to regular cleanup routine

  print_pointer_subroutine:
    push rbp
    mov rbp, rsp
    sub rsp, 80

    mov [rsp+8],  rdi
    mov [rsp+16], rsi
    mov [rsp+24], rdx
    mov [rsp+32], rcx
    mov [rsp+40], r8
    mov [rsp+48], r9
    mov [rsp+56], r10
    mov [rsp+64], r11

    mov rdi, print_pointer
    mov rsi, [rsp+8]
    call printf

    mov rdi, [rsp+8]
    mov rsi, [rsp+16]
    mov rdx, [rsp+24]
    mov rcx, [rsp+32]
    mov r8,  [rsp+40]
    mov r9,  [rsp+48]
    mov r10, [rsp+56]
    mov r11, [rsp+64]

    add rsp, 80
    pop rbp
    ret

;
; ... you might be an assembly programmer
;
; if you use DWORD to save 4 bytes in your executable
; if you know what a self-referential pointer is and regularly use it
;
