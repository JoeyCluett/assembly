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
    push rbp
    mov rbp, rsp    ; rbp now points at its own previous value this creates a 'stack trace'
    sub rsp, 80    ; allocate 80 bytes for local storage

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

    mov [rsp+8],  rdi
    mov [rsp+16], rsi
    mov [rsp+24], rdx
    mov [rsp+32], rcx

    mov rdi, image_size_fmt
    mov rsi, [rsp+24]
    mov rdx, [rsp+32]
    call printf

    mov rdi, [rsp+8]
    mov rsi, [rsp+16]
    mov rdx, [rsp+24]
    mov rcx, [rsp+32]

    ; now the actual calculation can begin
    ; first subtract 2 from each dimension
    sub rdx, 2  ; img h
    sub rcx, 2  ; img w
    shl rcx, 3      ; rcx will be treated like a raw byte offset

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

    mov r10, r8     ; r8 is the current vertical index
    imul r10, rcx   ; generate the byte offset for this row
    add r10, r9     ; r9 is the byte offset of the current element
    add r10, rdi    ; add the base pointer before fetching

    movsd xmm1, QWORD [sobel] ; fetch upper left sobel coeffient
    mulsd xmm1, QWORD [r10]   ; fetch the current element
    addsd xmm0, xmm1    ; add to the cumulative sum for this window

    ; look at this awesome clusterf*ck of RAW and WAW hazards!!

    movsd xmm1, QWORD [sobel + 8]
    mulsd xmm1, QWORD [r10 + 8]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 16]
    mulsd xmm1, QWORD [r10 + 16]
    addsd xmm0, xmm1

    movsd xmm1, QWORD [sobel + 24]
    mulsd xmm1, QWORD [r10 + 24]
    addsd xmm0, xmm1

    ; ....................................................
    ; we aren't done evaluating the Sobel operator but 
    ; i want to get some intermediate results rn
    ; ....................................................

    ; we can calculate the destination address using r10 as its no longer needed at this point
    mov r10, ...
    mov r11, ...

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
    add rsp, 80 ; deallocate the stack space we requested
    pop rbp     ; remove this part of the stack trace
    ret         ; jump back to caller

    ; exceptional condition: invalid image size
  invalid_image_size:
    jmp clean_and_return ; jump to regular cleanup routine






;
; ... you might be an assembly programmer
;
; if you use DWORD to save 4 bytes in your executable
; if you know what a self-referential pointer is and regularly use it
; 
