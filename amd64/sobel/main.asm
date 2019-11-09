;
; this assembly routine acts as a gatekeeper of sorts for determining
; which other sobel routine to call: general purpose or simd
;

extern printf
extern apply_gp_sobel
extern apply_simd_sobel ; a 4x SIMD routine. requries support for certain avx extensions
global sobel

section .data
    ;sobel_jump_lut: dq apply_gp_sobel, apply_simd_sobel
    sobel_jump_lut: dq apply_gp_sobel, test_apply_simd

    normal_ret_val:  dq 0x00000000
    simd_no_support: dq 0x00000001

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

  ; when trying to use the SIMD routine, make sure the CPU suports it first
  test_apply_simd:

    ; stack frame
    push rbp
    mov rbp, rsp

    push rdx  ; save these as they will be overwritten by cpuid
    push rcx  ; ...

    mov eax, 7  ; prep cpuid to get extended cpu features
    mov ecx, 0  ; ...
    cpuid

    pop rcx ; restore the overwritten regisers that we saved
    pop rdx ; ...

    ; cpu information will overwrite ebx, ecx, edx
    ; avx2 flag is ebx[5]
    and ebx, DWORD 0x0010
    cmp ebx, 0x0010
    jne use_gp_sobel

    ; the avx2 bit is true, use the optimized version
    call apply_simd_sobel

    pop rbp
    ret

  use_gp_sobel:
    ; the avx2 bit is false, use the gp vesion
    call apply_gp_sobel

    pop rbp
    ret
