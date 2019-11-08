;
; this assembly routine acts as a gatekeeper of sorts for determining
; which other sobel routine to call: general purpose or simd
;

extern printf
extern apply_gp_sobel
extern apply_simd_sobel ; a 4x SIMD routine. requries support for certain avx extensions
global sobel

section .data
    jump_lut: dq apply_gp_sobel, apply_simd_sobel

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
    call [r8 + jump_lut]
    ;add r8, jump_lut
    ;mov r8, [r8]
    ;call r8

  end_sobel:
    pop rbp
    ret
