;
; an assembly program using SDL for graphics work
;

; let compiler generate a _start function
; the main.c file calls this routine directly
global _main

; start nice and easy
extern SDL_Init
extern SDL_Quit
extern setvideomode
extern SDL_Delay

section .data 
    INIT_EVERYTHING: dq 0x0000FFFF
    HW_SURFACE:      dq 0x00000001
    DOUBLE_BUFFER:   dq 0x40000000
    WIDTH:           dq 300
    HEIGHT:          dq 200

section .text
_main:

    ; setup a stack frame
    ;push rbp
    ;mov rbp, rsp

    ; gonna use this place to store pointer to current context 
    ; because it is required to be unmodified across function calls
    push rbx

    mov rdi, INIT_EVERYTHING ; need to tell SDL what we want
    call SDL_Init

    ; create a window 300 pixels wide and 200 pixels tall
    mov rdi, WIDTH              ; 300 pixels wide
    mov rsi, HEIGHT             ; 200 pixels high
    mov rdx, DWORD 32           ; 32 bits per pixel
    mov rcx, [HW_SURFACE]       ; combine flags
    or  rcx, [DOUBLE_BUFFER]    ; ...

    ; the above 5 instructions have led to this moment
    call setvideomode

    ; preserve the SDL_Surface pointer
    mov rbx, rax

    mov rdi, QWORD 1000
    call SDL_Delay  ; delay for 1000 ms

    call SDL_Quit

    ; clean up resources that we used during the call
    xor rax, rax
    pop rbx
    ;pop rbp
    ret
