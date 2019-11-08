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
; a huge optimization made in this program is ignoring the center
; row entirely as the results are known to be zero. we will have
; to see if the compiler makes the same optimization
;
; this program does not pad anything. it simply ignores the
; outermost rows and columns of the input image
;

extern printf

global apply_gp_sobel

; .data section stores the data for the Sobel operator. this can be changed
section .data
    ;sobel:      dq -1.0, -2.0, -1.0
    ;sobelr1:    dq  0.0,  0.0,  0.0
    ;sobelr2:    dq  1.0,  2.0,  1.0

    ; create constants that can be used instead if the add/index instructions
    sobel0: dq -1.0
    sobel1: dq -2.0
    sobel2: dq -1.0
    sobel3: dq  0.0
    sobel4: dq  0.0
    sobel5: dq  0.0
    sobel6: dq  1.0
    sobel7: dq  2.0
    sobel8: dq  1.0

section .text
apply_gp_sobel:
    ; create stack frame
    push rbp        ; save the previous value of rbp
    mov rbp, rsp    ; rbp now points at its own previous value this creates a 'stack trace'
    sub rsp, 72     ; allocate space for local storage

    ;
    ; arguments:
    ; rdi : src image
    ; rsi : dest image
    ; rdx : image height
    ; rcx : image width
    ;

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

    ; now modify rsi such that it points to the first destination space
    add rsi, rcx
    add rsi, 24

    xor r8, r8 ; height track
    ;xor r9, r9 ; width track

  outer_loop:

    xor r9, r9  ; zero out every width iteration

  inner_loop:

    ; ========================================
    ; HERE BE DRAGONS
    ; ========================================

    ; the cumulative sum is generated across all 16 of the xmmN registers
    subsd xmm0, xmm0

    ; preserve the global window pointer
    mov r10, rdi    ; modify a copy of the current window pointer

    subsd xmm10, xmm10
    subsd xmm11, xmm11

    movsd xmm1, QWORD [sobel0]
    mulsd xmm1, QWORD [r10 + 0]
    addsd xmm10, xmm1

    movsd xmm2, QWORD [sobel1]
    mulsd xmm2, QWORD [r10 + 8]
    addsd xmm11, xmm2

    movsd xmm3, QWORD [sobel2]
    mulsd xmm3, QWORD [r10 + 16]
    addsd xmm0, xmm3

    addsd xmm10, xmm11

    add r10, rcx  ; jump to the next row in the src array
    add r10, 16

    subsd xmm12, xmm12
    subsd xmm13, xmm13

    movsd xmm4, QWORD [sobel3]
    mulsd xmm4, QWORD [r10 + 0]
    addsd xmm12, xmm4

    movsd xmm5, QWORD [sobel4]
    mulsd xmm5, QWORD [r10 + 8]
    addsd xmm13, xmm5

    movsd xmm6, QWORD [sobel5]
    mulsd xmm6, QWORD [r10 + 16]
    addsd xmm0, xmm6

    addsd xmm12, xmm13

    add r10, rcx   ; jump to the next row in the src array
    add r10, 16

    subsd xmm14, xmm14
    subsd xmm15, xmm15

    movsd xmm7, QWORD [sobel6]
    mulsd xmm7, QWORD [r10]
    addsd xmm14, xmm7

    movsd xmm8, QWORD [sobel7]
    mulsd xmm8, QWORD [r10 + 8]
    addsd xmm15, xmm8

    movsd xmm9, QWORD [sobel8]
    mulsd xmm9, QWORD [r10 + 16]
    addsd xmm0, xmm9

    addsd xmm14, xmm15

    ; xmm0 = xmm0 + xmm10 + xmm12 + xmm14
    addsd xmm0, xmm10
    addsd xmm12, xmm14
    addsd xmm0, xmm12

    ; store data in destination register, xmm0 is the total sum for this window
    movsd [rsi], xmm0

    add rdi, 8  ; next window start
    add rsi, 8  ; next destination

    ; condition for next x
    add r9, 8
    cmp r9, rcx
    jl inner_loop

    ; after every row, advance the array pointer to the next one
    add rdi, 16 ; next row of source
    add rsi, 16 ; next row of dest

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

    ; print some kind of error message

    jmp clean_and_return ; jump to regular cleanup routine

;
;
; if you use DWORD to save 4 bytes of space
; if you know what a self-referential pointer is and regularly use it
; if the idea of framing something gives you nightmares
; if you envy ARM and MIPS developers only because 32 is bigger than 16
;
; ... you might be an assembly programmer
;
;
