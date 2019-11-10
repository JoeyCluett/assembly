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

global apply_simd_sobel

; .data section stores the data for the Sobel operator. this can be changed
section .data
    align 32
    sobelr0: dq -1.0, -2.0, -1.0,  0.0 ; this data is all padded with an extra zero to fit into a full xmmN register
    align 32
    sobelr1: dq  0.0,  0.0,  0.0,  0.0
    align 32
    sobelr2: dq  1.0,  2.0,  1.0,  0.0

    align 32
    sobelr0_shr: dq  0.0, -1.0, -2.0, -1.0
    align 32
    sobelr1_shr: dq  0.0,  0.0,  0.0,  0.0
    align 32
    sobelr2_shr: dq  0.0,  1.0,  2.0,  1.0

    print_pointer: db "Ptr: %p", 0xA, 0x0

section .text
apply_simd_sobel:
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

    ;push rdi
    ;mov rdi, sobelr0
    ;call print_pointer_subroutine
    ;pop rdi

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

    ; load the sobel into the proper registers
    vmovapd ymm0, [sobelr0] ; load 4 aligned packed doubles
    vmovapd ymm1, [sobelr1] ; ...
    vmovapd ymm2, [sobelr2] ; ...

    vmovapd ymm3, [sobelr0_shr]
    vmovapd ymm4, [sobelr1_shr]
    vmovapd ymm5, [sobelr2_shr]

  outer_loop:

    xor r9, r9  ; zero out every width iteration

  inner_loop:

    ; ========================================
    ; HERE BE DRAGONS
    ; ========================================

    ; preserve the global window pointer
    mov r10, rdi    ; modify a copy of the current window pointer

    vmovupd ymm6, [r10] ; read 4 doubles in one sweep

    lea r10, [r10 + 1*rcx + 16]    ; r10 = r10 + rcx + 16
    vmovupd ymm7, [r10]

    lea r10, [r10 + 1*rcx + 16]    ; r10 = r10 + rcx + 16
    vmovupd ymm8, [r10]

    ; we need copies of that window data
    vmovapd ymm9,  ymm6
    vmovapd ymm10, ymm7
    vmovapd ymm11, ymm8

    ; ---------------------------------
    ; element n   = [ ymm6 ; ymm7  ; ymm8  ]
    ; element n+1 = [ ymm9 ; ymm10 ; ymm11 ]
    ; ---------------------------------

    ; we can now generate partial sums for two adjacent dest elments
    ;vmulpd ymm6, ymm0   ; element n, generate top row
    ;vmulpd ymm7, ymm1   ; element n, generate middle row
    ;vmulpd ymm8, ymm2   ; element n, generate bottom row

    ;vmulpd ymm9,  ymm3  ; element n+1, generate top row
    ;vmulpd ymm10, ymm4  ; element n+1, generate middle row
    ;vmulpd ymm11, ymm5  ; element n+1, generate bottom row

    vmulpd ymm6, [sobelr0]   ; element n, generate top row
    vmulpd ymm7, [sobelr1]   ; element n, generate middle row
    vmulpd ymm8, [sobelr2]   ; element n, generate bottom row

    vmulpd ymm9,  [sobelr0_shr]  ; element n+1, generate top row
    vmulpd ymm10, [sobelr1_shr]  ; element n+1, generate middle row
    vmulpd ymm11, [sobelr2_shr]  ; element n+1, generate bottom row

    vaddpd ymm8, ymm6   ; element n, add bottom and top row
    vaddpd ymm8, ymm7   ; element n, add bottom and middle row

    vaddpd ymm11, ymm9  ; element n+1, add bottom and top row
    vaddpd ymm11, ymm10 ; element n+1, add bottom and mddle row

    ; ymm8  contains partial sums for element n
    ; ymm11 contains partial sums for element n+1

    ; registers that can be reused: ymm6, ymm7, ymm9, ymm10
    vextracti128 xmm6, ymm8, 1  ; extract upper 128 bits of element n
    vextracti128 xmm9, ymm11, 1 ; extract upper 128 bits of eleent n+1

    addpd xmm8,  xmm6 ; element n,   add lower 128-bits to upper 128-bits
    addpd xmm11, xmm9 ; element n+1, add lower 128-bits to upper 128-bits

    vpermq ymm7,  ymm8,  0x01 ; element n,   extract the remaining 64-bit partial
    vpermq ymm10, ymm11, 0x01 ; element n+1, extract the remaining 64-bit partial

    addsd xmm8,  xmm7   ; element n,   add final partial sums
    addsd xmm11, xmm10  ; element n+1, add final partial sums

    ; ymm3 now contains all partial sums
    ;vmovupd [rsp], ymm3        ; store the full 256-bit chunk into memory
    ;movupd  xmm4, [rsp+16]     ; load the upper half into seperate register
    ;movsd   xmm5, [rsp+8]      ; load the upper half of the lower chunk
    ;addpd   xmm3, xmm4         ; this only works because we dont care about the most significant number
    ;addsd   xmm3, xmm5         ; add the last partial sum

    ; store data in destination array, xmm0 is the total sum for this window
    ;movsd [rsi], xmm3

    movsd [rsi],   xmm8
    movsd [rsi+8], xmm11

    add rdi, 16  ; next window start
    add rsi, 16  ; next destination

    ; condition for next x
    add r9, 16
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
    mov rax, 1  ; return 1 (sobel simd)
    ret         ; jump back to caller

    ; exceptional condition: invalid image size
  invalid_image_size:

    ; print some kind of error message

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
