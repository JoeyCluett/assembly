#!/bin/bash

file_ends=( ".lst" ".o" "" )
libs=( "addargs" "listiter" )

# remove all intermediate files if they exist
for l in "${libs[@]}"; do
    for f in "${file_ends[@]}"; do
        if [ -f "${l}/${l}${f}" ]; then
            rm ${l}/${l}${f}
        fi
    done
done

# generate object code from asm file
for f in "${libs[@]}"; do
    nasm -f elf -g -F dwarf ${f}/${f}.asm -l ${f}/${f}.lst
done

# generate asm file from C
gcc -m32 -Os -S main.c 

# place object files together to build a link command
fin=""
for l in "${libs[@]}"; do
    fin="$fin ${l}/${l}.o"
done

gcc -m32 -g -c -o main.o main.c
gcc -m32 -g -o main main.o ${fin} # let gcc link and add debug symbols (-g) for us
