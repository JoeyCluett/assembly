;
; call assembly routine from C
; this one adds a few integers in an array
;
; long int add_intt( long int* data, int size );
; expects:
;   rdi -> data pointer
;   rsi -> size of data
;
; returns
;   rax -> sum of data
;

global add_ints

    section .text
add_ints:
    xor rax, rax    ; zero out rax so we can add to it

    cmp rsi, 0      ; compare starting value of size
    jz end_add_ints ; jump to end if theres nothing to add

  loop_start:
    mov rdx, QWORD [rdi]  ; load the first data
    add rax, rdx    ; generate a cumulative sum
    add rdi, 8      ; advance pointer to next data
    dec rsi         ; decrement remaining size
    jnz loop_start

  end_add_ints:
    ret ; sum is already stored in rax

