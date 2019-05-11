#!/bin/bash

file_ends=( ".lst" ".o" "" )
filename="math"

# remove all intermediate files if they exist
for f in "${file_ends[@]}"; do
    if [ -f "${filename}" ]; then
        rm ${filename}${f}
    fi
done

#nasm -f elf -g -F stabs newsandbox.asm -l newsandbox.lst
nasm -f elf -g -F dwarf ${filename}.asm -l ${filename}.lst
ld -m elf_i386 -s -o ${filename} ${filename}.o
