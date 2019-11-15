;
; first code to run in the OS
;

global loader

;MAGIC_NUMBER equ 0x1BADB002
;FLAGS        equ 0x0
;CHECKSUM     equ -MAGIC_NUMBER

section .data
  align 4
header_start: dd 0xE85250D6 ; magic number
  mode: dd 0x00000000 ; protected mode
  checksum: dd 0x100000000 - ( 0xE85250D6 + header_end - header_start )
  type_:  dw 0
  flags_: dw 0
  size_:  dd 0
header_end: equ $ - header_start

section .text
align 4
loader:
    mov eax, 0xCAFEBABE

.loop:
    jmp .loop
