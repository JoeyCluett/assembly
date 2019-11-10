;
; this assembly routine acts as a gatekeeper of sorts for determining
; which other sobel routine to call: general purpose or simd
;

extern printf
extern apply_gp_sobel
extern apply_simd_sobel ; a 4x SIMD routine. requries support for certain avx extensions

global sobel
global init_sobel

section .data
    normal_ret_val:  dq 0x00000000
    simd_no_support: dq 0x00000001

section .bss
    align 32
    sobel_jump_lut: resb 16 ; enough space for two pointers

section .text
sobel:
    push rbp
    mov rbp, rsp

    ;
    ; arguments
    ;
    ;   rdi : src image
    ;   rsi : dest image
    ;   rdx : image height
    ;   rcx : image width
    ;   r8  : flag
    ;

    cmp r8, 2
    jge end_sobel
    shl r8, 3
    call [r8 + sobel_jump_lut]

  end_sobel:
    pop rbp
    ret

init_sobel:
    push rbp
    mov rbp, rsp

    push rax ; save these as they will be overwritten by cpuid
    push rbx ; ...
    push rcx ; ...
    push rdx ; ...

    ; fill all LUT entries with GP solution solver
    mov rax, apply_gp_sobel ; load into RAX because mem->mem operations arent supported (can you imagine?)
    mov [sobel_jump_lut],   rax
    mov [sobel_jump_lut+8], rax

    mov eax, 0x07  ; prep cpuid to get extended cpu features
    mov ecx, 0  ; ...
    cpuid

    ; cpu information will overwrite ebx, ecx, edx
    ; avx2 flag is ebx[5]
    and ebx, DWORD 0x0020
    cmp ebx, 0x0020
    jne end_init_sobel

    ; place the SIMD routine in the LUT
    mov rax, apply_simd_sobel
    mov [sobel_jump_lut + 8], rax

  end_init_sobel:

    pop rdx ; restore the overwritten regisers that we saved
    pop rcx ; ...
    pop rbx ; ...
    pop rax ; ...

    pop rbp
    ret
