;
; call a user defined function from assembly
; user function does not accept arguments of return anything
;

global main
extern call_user_function
extern print_long
extern add_13

section .data
; no data this time around

section .text
main:
    ; call_user_function does not take or return anything
    call call_user_function
    xor rax, rax
    
    ; print_long takes a single argument but does not return anything
    mov rdi, 1000000000
    call print_long

    ; add_13 takes a single parameter and returns a long int
    mov rdi, 13
    call add_13
    mov rdi, rax    ; result of add_13 is in rax
    call print_long

    ret
