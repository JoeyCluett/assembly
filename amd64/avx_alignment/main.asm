;
; Asm program to print address and associated double 
; values to figure out memory alignment of __m_256 datatypes
;

extern printf
extern puts

global poke_avx_alignment

; .data section stores the data for the Sobel operator. this can be changed
section .data
    ;align 32 ; needs to be aligned to support the vmovapd instruction
    sample_data: dq 1.0, 2.0, 3.0, 4.0

    print_double_fmt: db "%lf ", 0x0
    print_pointer_fmt: db "%p ", 0x0
    print_newline_fmt: db 0x0
    print_ptr_double_fmt: db "Ptr: %10ld -> %10lf", 0xA, 0x0

section .text
poke_avx_alignment:
    ; create stack frame
    push rbp        ; save the previous value of rbp
    mov rbp, rsp    ; rbp now points at its own previous value this creates a 'stack trace'
    sub rsp, 64     ; allocate space for local storage

    ; print the first data member (xmm0.sd) after load
    vmovupd ymm1, [sample_data]     ; read data into wide vector register
    vmovupd [rsp+0], ymm1          ; push this data into local storage 
                                    ; giving 32 bytes for full register
    
    movsd xmm0, QWORD [sample_data]
    mov rdi, sample_data
    call print_ptr_double_subroutine

    ; load each element of the stored vector
    movsd xmm0, QWORD [rsp+0]
    mov rdi, rsp
    add rdi, 0
    call print_ptr_double_subroutine

    movsd xmm0, QWORD [rsp+8]
    mov rdi, rsp
    add rdi, 8
    call print_ptr_double_subroutine

    movsd xmm0, QWORD [rsp+16]
    mov rdi, rsp
    add rdi, 16
    call print_ptr_double_subroutine

    movsd xmm0, QWORD [rsp+24]
    mov rdi, rsp
    add rdi, 24
    call print_ptr_double_subroutine


  clean_and_return:
    ; destroy stack frame
    add rsp, 64 ; deallocate the stack space we requested
    pop rbp     ; remove this part of the stack trace
    ret         ; jump back to caller

  invalid_image_size:
    ; print some kind of error message
    jmp clean_and_return ; jump to regular cleanup routine

  print_newline_subroutine:
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

    mov rdi, print_newline_fmt
    call puts

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

  print_ptr_double_subroutine:
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
    movsd [rsp+72], xmm0

    mov rdi, print_ptr_double_fmt
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
    movsd xmm0, [rsp+72]

    add rsp, 80
    pop rbp
    ret

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

    mov rdi, print_pointer_fmt
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

  print_double_subroutine:
    push rbp
    mov rbp, rsp
    sub rsp, 96

    mov   [rsp+8],  rdi
    mov   [rsp+16], rsi
    mov   [rsp+24], rdx
    mov   [rsp+32], rcx
    mov   [rsp+40], r8
    mov   [rsp+48], r9
    mov   [rsp+56], r10
    mov   [rsp+64], r11
    movsd [rsp+72], xmm0

    mov rdi, print_double_fmt
    call printf

    mov   rdi,  [rsp+8]
    mov   rsi,  [rsp+16]
    mov   rdx,  [rsp+24]
    mov   rcx,  [rsp+32]
    mov   r8,   [rsp+40]
    mov   r9,   [rsp+48]
    mov   r10,  [rsp+56]
    mov   r11,  [rsp+64]
    movsd xmm0, [rsp+72]

    add rsp, 96
    pop rbp
    ret
