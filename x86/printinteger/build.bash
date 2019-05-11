#!/bin/bash

file_ends=( ".lst" ".o" "" )
filename="printinteger"

# remove all intermediate files if they exist
for f in "${file_ends[@]}"; do
    if [ -f "${filename}" ]; then
        rm ${filename}${f}
    fi
done

# old method of creating ELF
#nasm -f elf -g -F stabs newsandbox.asm -l newsandbox.lst
#ld -m elf_i386 -s -o ${filename} ${filename}.o

# new way of generating executable
nasm -f elf -g -F dwarf ${filename}.asm -l ${filename}.lst
#gcc -m32 -g -o ${filename} ${filename}.o # let gcc link and add debug symbols for us
