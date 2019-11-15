#!/bin/bash

file_ends=( ".lst" ".o" "" )
filename="newsandbox"

# remove all intermediate files if they exist
for f in "${file_ends[@]}"; do
    if [ -f "${filename}" ]; then
        rm ${filename}${f}
    fi
done

#nasm -f elf -g -F stabs newsandbox.asm -l newsandbox.lst
nasm -f elf -g -F dwarf newsandbox.asm -l newsandbox.lst
#ld -m elf_i386 -s -o newsandbox newsandbox.o
