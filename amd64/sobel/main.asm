;
; an assembly program using SDL for graphics work
;

; let compiler generate a _start function
; the main.c file calls this routine directly
global _main

extern printf
extern puts
extern scanf

; start nice and easy
extern SDL_Init
extern SDL_Quit
extern SDL_SetVideoMode
extern SDL_Delay

section .data 
    INIT_EVERYTHING:    dq 0x0000FFFF
    HW_SURFACE:         dq 0x00000001
    DOUBLE_BUFFER:      dq 0x40000000
    WIDTH:              dq 300
    HEIGHT:             dq 200

    sdlinit_success:    db "sdlinit was successful", 0x0
    sdlinit_format:     db "sdlinit returned: %d", 0xA, 0x0
    screensize:         db "screen width: %d, screen height: %d", 0xA, 0x0
    read_double:        db "%lf", 0x0

section .text
_sub_read_double:
    push 

_main:

    ; gonna use this place to store pointer to current context 
    ; because it is required to be unmodified across function calls
    push rbx

    mov rdi, INIT_EVERYTHING ; need to tell SDL what we want
    ;call QWORD [sdlinit]
    call SDL_Init

    ; print the return value from sdlinit
    mov rdi, sdlinit_format ; load the format string
    mov rsi, rax            ; sdlinit placed something here
    call printf

    cmp eax, -1
    jz cleanup

    ; print the size of the screen requested
    mov rdi, screensize ; format string
    mov rsi, [WIDTH]    ; width
    mov rdx, [HEIGHT]   ; height
    call printf

    ; create a window 300 pixels wide and 200 pixels tall
    mov rdi, [WIDTH]              ; 300 pixels wide
    mov rsi, [HEIGHT]             ; 200 pixels high
    mov rdx, DWORD 32           ; 32 bits per pixel
    mov rcx, [HW_SURFACE]       ; combine flags
    or  rcx, [DOUBLE_BUFFER]    ; ...

    ; the above 5 instructions have led to this moment
    call SDL_SetVideoMode

    ; preserve the SDL_Surface pointer
    mov rbx, rax

    mov rdi, QWORD 3000
    call SDL_Delay

    ; sdlquit cleans up our sdl surface pointer
    call SDL_Quit

  cleanup:
    ; clean up resources that we used during the call
    mov rax, 2600
    pop rbx
    ret
