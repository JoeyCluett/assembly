#!/bin/bash


yasm -f elf64 -g dwarf2 -l main.lst main.asm -o asm.o
gcc -c -o main.o main.c
gcc -o main main.o asm.o
