section .data
    int_string: db 0x25, "d", 0x0a, 0x00
    ;               %     d    \n    \0
section .bss
section .text

extern printf

;
;   A run length encoder implementation
;   
;

